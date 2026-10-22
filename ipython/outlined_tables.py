"""IPython startup file: molten.lua points PYTHONSTARTUP here before its first kernel starts.

A DataFrame shown as cell output renders as a table outlined in box-drawing characters instead of pandas' bare columns.
pandas' own limits apply: display.max_rows and display.min_rows cut the rows, display.max_columns the columns, and a
table wider than display.width continues in a second box below, as pandas wraps its own output. print(df) and the HTML
that JupyterLab shows stay pandas' own. A plain python prompt skips the file; a PYTHONSTARTUP set before Neovim started
runs first. A kernel moves into the folder named in the file that _999RPM_KERNEL_CWD points at (utils/jupyter.lua),
the notebook's own, so the modules beside the notebook import as they do in JupyterLab.
"""


def _rpm999_startup():
    import os
    import sys

    previous = os.environ.get("_999RPM_PYTHONSTARTUP", "")
    if previous != os.environ.get("PYTHONSTARTUP") and os.path.isfile(previous):
        with open(previous, encoding="utf-8") as file:
            exec(compile(file.read(), previous, "exec"), globals())
    try:
        shell = get_ipython()  # noqa: F821  IPython defines it in the user namespace
    except NameError:
        return

    if "ipykernel" in sys.modules:  # a kernel, not an IPython prompt in a terminal
        try:
            with open(os.environ.get("_999RPM_KERNEL_CWD", ""), encoding="utf-8") as file:
                folder = file.read().strip()
            if os.path.isdir(folder):
                os.chdir(folder)
        except OSError:
            pass  # no file: the kernel stays in the host's folder

    import unicodedata

    def width(text):
        return sum(2 if unicodedata.east_asian_width(char) in "WF" else 1 for char in text)

    def pad(text, size, right):
        fill = " " * (size - width(text))
        return fill + text if right else text + fill

    def label(key):
        return " ".join(map(str, key)) if isinstance(key, tuple) else ("" if key is None else str(key))

    def cells(frame, position):  # pandas' formatting of one column, so floats keep its precision
        text = frame.iloc[:, [position]].to_string(index=False, header=False)
        return [line.strip() for line in text.split("\n")]

    def render(frame):
        import pandas as pd

        rows, cols = frame.shape
        if rows == 0 or cols == 0:
            return None
        max_rows = pd.get_option("display.max_rows")
        min_rows = pd.get_option("display.min_rows") or max_rows or rows
        max_cols = pd.get_option("display.max_columns") or 20
        limit = pd.get_option("display.width") if pd.get_option("display.expand_frame_repr") else 0
        cut_rows = max_rows is not None and rows > max_rows
        cut_cols = cols > max_cols
        half_rows = max(min(min_rows, max_rows or rows) // 2, 1)
        half_cols = max(max_cols // 2, 1)
        shown = pd.concat([frame.iloc[:half_rows], frame.iloc[-half_rows:]]) if cut_rows else frame
        if cut_cols:
            shown = pd.concat([shown.iloc[:, :half_cols], shown.iloc[:, -half_cols:]], axis=1)

        index = shown.index.to_frame(index=False)
        levels = shown.index.nlevels
        table = [(label(name), cells(index, level), False) for level, name in enumerate(shown.index.names)]
        table += [(label(key), cells(shown, position), True) for position, key in enumerate(shown.columns)]
        if cut_cols:
            table.insert(levels + half_cols, ("…", ["…"] * len(shown), True))
        sizes = [max([width(head)] + [width(cell) for cell in column]) for head, column, _ in table]

        def box(picked):
            def rule(left, middle, right):
                return left + middle.join("─" * (sizes[i] + 2) for i in picked) + right

            def row(values):
                return "│ " + " │ ".join(pad(values[i], sizes[i], table[i][2]) for i in picked) + " │"

            body = [row([column[r] for _, column, _ in table]) for r in range(len(shown))]
            if cut_rows:
                body.insert(half_rows, row(["…"] * len(table)))
            header = row([head for head, _, _ in table])
            return "\n".join([rule("╭", "┬", "╮"), header, rule("├", "┼", "┤"), *body, rule("╰", "┴", "╯")])

        base = list(range(levels))
        start = 1 + sum(sizes[i] + 3 for i in base)
        chunks, chunk, used = [], [], start
        for i in range(levels, len(table)):
            if chunk and limit and used + sizes[i] + 3 > limit:
                chunks.append(chunk)
                chunk, used = [], start
            chunk.append(i)
            used += sizes[i] + 3
        chunks.append(chunk)
        text = "\n\n".join(box(base + part) for part in chunks)
        if cut_rows or cut_cols:
            text += f"\n\n[{rows} rows x {cols} columns]"
        return text

    def show(frame, printer, cycle):
        text = None
        if not cycle:
            try:
                text = render(frame)
            except Exception:  # an unusual frame falls back to pandas' own text instead of losing the output
                text = None
        printer.text(repr(frame) if text is None else text)

    formatter = shell.display_formatter.formatters["text/plain"]
    for module in ("pandas", "pandas.core.frame"):  # pandas 3 names the class's module "pandas", pandas 2 the full path
        formatter.for_type_by_name(module, "DataFrame", show)


_rpm999_startup()
del _rpm999_startup
