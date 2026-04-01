import traceback

import pythoncom
import win32com.client


def main():
    pythoncom.CoInitialize()

    try:
        print("Подключение к открытой Renga...")
        app = win32com.client.GetActiveObject("Renga.Application.1")
        project = app.Project
        objects = project.Model.GetObjects()

        column_type_id = "{d9ee2442-e807-42fb-8fe5-9dcfe543035d}"
        mark_group_id = "{be8b433a-ee51-49de-8189-5f6476783e22}"
        ordinal_id = "{02e22308-ee6e-4d47-8b87-cbf23aa97548}"

        groups = {}
        columns_found = 0

        print("Чтение объектов проекта...")
        for i in range(objects.Count):
            try:
                obj = objects.GetByIndex(i)
                if str(obj.ObjectTypeS).lower() != column_type_id:
                    continue

                columns_found += 1
                props = obj.GetProperties()
                mark_prop = props.GetS(mark_group_id)
                if mark_prop is None:
                    print(f"Колонка Id={obj.Id}: не найдено свойство 'Марка группы' ({mark_group_id})")
                    continue

                mark = str(mark_prop.GetStringValue())
                groups.setdefault(mark, []).append((int(obj.Id), obj))
            except Exception as error:
                print(f"Ошибка при чтении объекта с индексом {i}: {error}")

        print(f"Найдено колонн: {columns_found}")
        print(f"Найдено групп по 'Марка группы': {len(groups)}")

        print("Запись порядковых номеров...")
        operation = project.CreateOperation()
        operation.Start()

        written = 0
        write_errors = 0
        readback_errors = 0
        sample_logs = []
        for mark in sorted(groups):
            for number, (_, obj) in enumerate(sorted(groups[mark]), start=1):
                try:
                    ordinal_prop = obj.GetProperties().GetS(ordinal_id)
                    if ordinal_prop is None:
                        print(
                            f"Колонка Id={obj.Id}: не найдено свойство "
                            f"'Порядковый номер в группе' ({ordinal_id})"
                        )
                        write_errors += 1
                        continue

                    ordinal_prop.SetIntegerValue(number)
                    written += 1

                    try:
                        read_back = ordinal_prop.GetIntegerValue()
                        if read_back != number:
                            readback_errors += 1
                            print(
                                f"Колонка Id={obj.Id}: после записи ожидалось {number}, "
                                f"но прочитано {read_back}"
                            )
                        elif len(sample_logs) < 10:
                            sample_logs.append(
                                f"Id={obj.Id}; Марка группы={mark}; записано={number}; прочитано={read_back}"
                            )
                    except Exception as error:
                        readback_errors += 1
                        print(f"Колонка Id={obj.Id}: ошибка чтения после записи: {error}")
                except Exception as error:
                    write_errors += 1
                    print(f"Ошибка записи номера для колонки Id={obj.Id}: {error}")

        operation.Apply()
        print(f"Записано порядковых номеров: {written}")
        print(f"Ошибок записи: {write_errors}")
        print(f"Ошибок чтения после записи: {readback_errors}")
        if sample_logs:
            print("Примеры успешной записи:")
            for line in sample_logs:
                print(line)
        print("Готово.")

    except Exception as error:
        print("Скрипт завершился с ошибкой:")
        print(error)
        print()
        print(traceback.format_exc())
        input("Нажмите Enter, чтобы закрыть окно...")
        raise


if __name__ == "__main__":
    main()
