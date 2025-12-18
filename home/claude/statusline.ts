#!/usr/bin/env -S deno run --allow-read
/**
 * Claude Code statusline script to display context window usage.
 * Reads JSON from stdin, parses transcript file, and outputs usage info.
 */

interface Usage {
  input_tokens?: number;
  output_tokens?: number;
  cache_creation_input_tokens?: number;
  cache_read_input_tokens?: number;
  cache_creation?: {
    ephemeral_5m_input_tokens?: number;
    ephemeral_1h_input_tokens?: number;
  };
}

interface TranscriptMessage {
  message?: {
    usage?: Usage;
  };
}

interface StatusLineInput {
  model?: {
    id?: string;
    display_name?: string;
  };
  transcript_path?: string;
  exceeds_200k_tokens?: boolean;
}

// Context window sizes by model
const CONTEXT_SIZES: Record<string, number> = {
  "claude-opus-4-5-20251101": 200000,
  "claude-sonnet-4-5-20250929": 200000,
  "claude-sonnet-4-20250514": 200000,
  "claude-opus-4-20250514": 200000,
  "default": 200000,
};

function formatTokens(n: number): string {
  if (n >= 1000) {
    return `${(n / 1000).toFixed(1)}K`;
  }
  return String(n);
}

async function readTranscriptUsage(
  transcriptPath: string,
): Promise<{ usedTokens: number }> {
  let latestUsage: Usage | null = null;

  try {
    const content = await Deno.readTextFile(transcriptPath);
    const lines = content.trim().split("\n");

    // Find the latest message with usage info
    for (const line of lines) {
      try {
        const entry = JSON.parse(line) as TranscriptMessage;
        const usage = entry.message?.usage;
        if (usage) {
          latestUsage = usage;
        }
      } catch {
        // Skip malformed lines
      }
    }
  } catch {
    // File not found or read error
  }

  if (!latestUsage) {
    return { usedTokens: 0 };
  }

  // Current context = input + cache_creation + cache_read (what's in the context window now)
  const usedTokens = (latestUsage.input_tokens ?? 0) +
    (latestUsage.cache_creation_input_tokens ?? 0) +
    (latestUsage.cache_read_input_tokens ?? 0);

  return { usedTokens };
}

async function main(): Promise<void> {
  const decoder = new TextDecoder();
  const chunks: Uint8Array[] = [];

  for await (const chunk of Deno.stdin.readable) {
    chunks.push(chunk);
  }

  let offset = 0;
  const combined = new Uint8Array(
    chunks.reduce((acc, c) => acc + c.length, 0),
  );
  for (const chunk of chunks) {
    combined.set(chunk, offset);
    offset += chunk.length;
  }
  const jsonStr = decoder.decode(combined);

  let data: StatusLineInput;
  try {
    data = JSON.parse(jsonStr);
  } catch {
    console.log("--");
    return;
  }

  const model = data.model?.display_name ?? "Unknown";
  const modelId = data.model?.id ?? "default";
  const contextSize = CONTEXT_SIZES[modelId] ?? CONTEXT_SIZES["default"];
  const transcriptPath = data.transcript_path;

  if (!transcriptPath) {
    console.log(`${model} | No transcript`);
    return;
  }

  const { usedTokens } = await readTranscriptUsage(transcriptPath);
  const percentUsed = Math.min(
    100,
    Math.floor((usedTokens * 100) / contextSize),
  );

  // Create visual progress bar
  const barWidth = 10;
  const filled = Math.floor((percentUsed * barWidth) / 100);
  const bar = "█".repeat(filled) + "░".repeat(barWidth - filled);

  // Warning indicator when usage is high
  const warning = data.exceeds_200k_tokens ? " ⚠️" : "";

  console.log(
    `${model} | [${bar}] ${percentUsed}% | ${formatTokens(usedTokens)}/${
      formatTokens(contextSize)
    }${warning}`,
  );
}

main();
