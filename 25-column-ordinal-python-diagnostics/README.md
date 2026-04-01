Запуск:

```powershell
cd C:\Users\RoyalZefa\Documents\MyRengaStyle
python -m pip install pywin32
python .\25-column-ordinal-python-diagnostics\app.py
```

Что делает скрипт:

- подключается к уже открытой Renga;
- ищет колонны;
- группирует их по свойству `Марка группы`;
- записывает `1, 2, 3, ...` в свойство `Порядковый номер в группе`;
- печатает возникающие ошибки по чтению и записи свойств.
