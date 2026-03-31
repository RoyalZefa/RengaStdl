# 22-column-ordinal-python

Python version of the column numbering script for Renga.

What it does:
- connects to the already opened Renga project;
- finds all columns;
- groups them by `Марка группы`;
- writes `1, 2, 3, ...` to `Порядковый номер в группе`.

Files:
- `number_columns.py` - short working version
- `number_columns_commented.py` - commented version for study

Requirements:
- Python for Windows
- `pywin32`

Install `pywin32`:

```powershell
pip install pywin32
```

Run:

```powershell
python .\22-column-ordinal-python\number_columns.py
```
