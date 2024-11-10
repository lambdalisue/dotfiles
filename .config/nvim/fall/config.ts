import {
  composeRenderers,
  type Entrypoint,
  refineCurator,
  refineSource,
} from "jsr:@vim-fall/std@^0.2.0-pre.2";
import * as builtin from "jsr:@vim-fall/std@^0.2.0-pre.2/builtin";
import * as extra from "jsr:@vim-fall/extra@^0.1.0";

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

export const main: Entrypoint = (
  {
    defineItemPickerFromSource,
    defineItemPickerFromCurator,
    refineGlobalConfig,
  },
) => {
  refineGlobalConfig({
    coordinator: builtin.coordinator.modern,
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
      },
      defaultAction: "open",
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
      },
      defaultAction: "open",
    },
  );

  defineItemPickerFromSource(
    "file",
    refineSource(
      builtin.source.file({
        excludes: [
          /.*\/nvim\/pack\/.*/,
          /.*\/zsh\/\.addons\/.*/,
          /.*\/node_modules\/.*/,
          /.*\/target\/.*/,
          /.*\/.git\/.*/,
          /.*\/.svn\/.*/,
          /.*\/.hg\/.*/,
          /.*\/.ssh\/.*/,
          /.*\/.DS_Store$/,
        ],
      }),
      builtin.refiner.relativePath,
    ),
    {
      matchers: [builtin.matcher.fzf],
      renderers: [composeRenderers(
        builtin.renderer.smartPath,
        // Install https://www.nerdfonts.com/ to use this renderer
        builtin.renderer.nerdfont,
        //extra.renderer.nerdfont,
        //extra.renderer.devicons,
        //extra.renderer.nvimWebDevicons,
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

  defineItemPickerFromSource("line", builtin.source.line, {
    //matchers: [builtin.matcher.fzf],
    matchers: [extra.matcher.kensaku],
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
};
