import {
  composeActions,
  composeRenderers,
  type Entrypoint,
  refineCurator,
  refineSource,
} from "jsr:@vim-fall/std@^0.4.0";
import * as builtin from "jsr:@vim-fall/std@^0.4.0/builtin";
import * as extra from "jsr:@vim-fall/extra@^0.2.0";
import { SEPARATOR } from "jsr:@std/path@^1.0.8/constants";

const myPathActions = {
  ...builtin.action.defaultOpenActions,
  ...builtin.action.defaultSystemopenActions,
  ...builtin.action.defaultCdActions,
};

const myQuickfixActions = {
  ...builtin.action.defaultQuickfixActions,
  // Install https://github.com/thinca/vim-qfreplace to use this action
  "quickfix:qfreplace": builtin.action.quickfix({
    after: "Qfreplace",
  }),
};

const myMiscActions = {
  ...builtin.action.defaultEchoActions,
  ...builtin.action.defaultYankActions,
  ...builtin.action.defaultSubmatchActions,
};

const myFilterFile = (path: string) => {
  const excludes = [
    ".7z",
    ".DS_Store",
    ".avi",
    ".avi",
    ".bmp",
    ".class",
    ".dll",
    ".dmg",
    ".doc",
    ".docx",
    ".dylib",
    ".ear",
    ".exe",
    ".fla",
    ".flac",
    ".flv",
    ".gif",
    ".ico",
    ".id_ed25519",
    ".id_rsa",
    ".iso",
    ".jar",
    ".jpeg",
    ".jpg",
    ".key",
    ".mkv",
    ".mov",
    ".mp3",
    ".mp4",
    ".mpeg",
    ".mpg",
    ".o",
    ".obj",
    ".ogg",
    ".pdf",
    ".png",
    ".ppt",
    ".pptx",
    ".rar",
    ".so",
    ".swf",
    ".tar.gz",
    ".war",
    ".wav",
    ".webm",
    ".wma",
    ".wmv",
    ".xls",
    ".xlsx",
    ".zip",
  ];
  for (const exclude of excludes) {
    if (path.endsWith(exclude)) {
      return false;
    }
  }
  return true;
};

const myFilterDirectory = (path: string) => {
  const excludes = [
    "$RECYVLE.BIN",
    ".cache",
    ".git",
    ".hg",
    ".ssh",
    ".svn",
    "__pycache__", // Python
    "build", // C/C++
    "node_modules", // Node.js
    "target", // Rust
    `nvim${SEPARATOR}pack`,
    `zsh${SEPARATOR}.addons`,
  ];
  for (const exclude of excludes) {
    if (path.includes(`${SEPARATOR}${exclude}${SEPARATOR}`)) {
      return false;
    }
  }
  return true;
};

export const main: Entrypoint = (
  {
    defineItemPickerFromSource,
    defineItemPickerFromCurator,
    refineGlobalConfig,
  },
) => {
  refineGlobalConfig({
    // coordinator: builtin.coordinator.modern,
    coordinator: builtin.coordinator.modern({
      widthRatio: 0.90,
      heightRatio: 0.90,
    }),
    theme: builtin.theme.MODERN_THEME,
  });

  defineItemPickerFromCurator(
    "git-grep",
    refineCurator(
      builtin.curator.gitGrep,
      builtin.refiner.relativePath,
    ),
    {
      previewers: [builtin.previewer.file],
      actions: {
        ...myPathActions,
        ...myQuickfixActions,
        ...myMiscActions,
      },
      defaultAction: "open",
    },
  );

  // Install https://github.com/BurntSushi/ripgrep to use this curator
  defineItemPickerFromCurator(
    "rg",
    refineCurator(
      builtin.curator.rg,
      builtin.refiner.relativePath,
    ),
    {
      previewers: [builtin.previewer.file],
      actions: {
        ...myPathActions,
        ...myQuickfixActions,
        ...myMiscActions,
      },
      defaultAction: "open",
    },
  );

  defineItemPickerFromSource(
    "mru",
    refineSource(
      extra.source.mr,
      builtin.refiner.relativePath,
    ),
    {
      matchers: [builtin.matcher.fzf],
      renderers: [composeRenderers(
        builtin.renderer.smartPath,
        // Install https://www.nerdfonts.com/ to use this renderer
        builtin.renderer.nerdfont,
      )],
      previewers: [builtin.previewer.file],
      actions: {
        ...myPathActions,
        ...myQuickfixActions,
        ...myMiscActions,
        ...extra.action.defaultMrDeleteActions,
      },
      defaultAction: "open",
    },
  );
  defineItemPickerFromSource(
    "mrw",
    refineSource(
      extra.source.mr({ type: "mrw" }),
      builtin.refiner.cwd,
      builtin.refiner.relativePath,
    ),
    {
      matchers: [builtin.matcher.fzf],
      renderers: [composeRenderers(
        builtin.renderer.smartPath,
        // Install https://www.nerdfonts.com/ to use this renderer
        builtin.renderer.nerdfont,
      )],
      previewers: [builtin.previewer.file],
      actions: {
        ...myPathActions,
        ...myQuickfixActions,
        ...myMiscActions,
      },
      defaultAction: "open",
    },
  );
  defineItemPickerFromSource(
    "mrr",
    extra.source.mr({ type: "mrr" }),
    {
      matchers: [builtin.matcher.fzf],
      renderers: [composeRenderers(
        builtin.renderer.smartPath,
        // Install https://www.nerdfonts.com/ to use this renderer
        builtin.renderer.nerdfont,
      )],
      previewers: [builtin.previewer.file],
      actions: {
        ...myPathActions,
        ...myQuickfixActions,
        ...myMiscActions,
        "cd-and-open": composeActions(
          builtin.action.cd,
          builtin.action.open,
        ),
      },
      defaultAction: "cd-and-open",
    },
  );
  defineItemPickerFromSource(
    "mrd",
    extra.source.mr({ type: "mrd" }),
    {
      matchers: [builtin.matcher.fzf],
      renderers: [composeRenderers(
        builtin.renderer.smartPath,
        // Install https://www.nerdfonts.com/ to use this renderer
        builtin.renderer.nerdfont,
      )],
      previewers: [builtin.previewer.file],
      actions: {
        ...myPathActions,
        ...myQuickfixActions,
        ...myMiscActions,
        "cd-and-open": composeActions(
          builtin.action.cd,
          builtin.action.open,
        ),
      },
      defaultAction: "cd-and-open",
    },
  );

  defineItemPickerFromSource(
    "file",
    refineSource(
      builtin.source.file({
        filterFile: myFilterFile,
        filterDirectory: myFilterDirectory,
      }),
      builtin.refiner.relativePath,
    ),
    {
      matchers: [
        builtin.matcher.substring,
        builtin.matcher.regexp,
      ],
      sorters: [
        builtin.sorter.noop,
        builtin.sorter.lexical,
        builtin.sorter.lexical({ reverse: true }),
      ],
      renderers: [
        composeRenderers(
          builtin.renderer.smartPath,
          // Install https://www.nerdfonts.com/ to use this renderer
          builtin.renderer.nerdfont,
          //extra.renderer.nerdfont,
          //extra.renderer.devicons,
          //extra.renderer.nvimWebDevicons,
        ),
        builtin.renderer.noop,
      ],
      previewers: [
        builtin.previewer.file,
        builtin.previewer.noop,
      ],
      actions: {
        ...myPathActions,
        ...myQuickfixActions,
        ...myMiscActions,
      },
      defaultAction: "open",
    },
  );

  defineItemPickerFromSource("line", builtin.source.line, {
    matchers: [
      builtin.matcher.fzf,
      builtin.matcher.regexp,
      //extra.matcher.kensaku,
    ],
    previewers: [builtin.previewer.buffer],
    actions: {
      ...myQuickfixActions,
      ...myMiscActions,
      ...builtin.action.defaultOpenActions,
      ...builtin.action.defaultBufferActions,
    },
    defaultAction: "open",
  });

  defineItemPickerFromSource(
    "buffer",
    builtin.source.buffer({ filter: "bufloaded" }),
    {
      matchers: [builtin.matcher.fzf],
      previewers: [builtin.previewer.buffer],
      actions: {
        ...myQuickfixActions,
        ...myMiscActions,
        ...builtin.action.defaultOpenActions,
        ...builtin.action.defaultBufferActions,
      },
      defaultAction: "open",
    },
  );

  defineItemPickerFromSource("help", builtin.source.helptag, {
    matchers: [builtin.matcher.fzf],
    previewers: [builtin.previewer.helptag],
    actions: {
      ...myMiscActions,
      ...builtin.action.defaultHelpActions,
    },
    defaultAction: "help",
  });

  defineItemPickerFromSource("quickfix", builtin.source.quickfix, {
    matchers: [builtin.matcher.fzf],
    previewers: [builtin.previewer.buffer],
    actions: {
      ...myMiscActions,
      ...builtin.action.defaultOpenActions,
    },
    defaultAction: "open",
  });
};
