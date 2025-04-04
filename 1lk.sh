#!/bin/bash

# Функция для вывода списка пользователей
print_users() {
    echo "Список пользователей и их домашних директорий:"
    getent passwd | cut -d: -f1,6 | sort | column -t -s:
}

# Функция для вывода списка процессов
print_processes() {
    echo "Список запущенных процессов (PID):"
    ps -e -o pid= | sort -n | column -t
}

# Функция для вывода справки
print_help() {
    echo "Использование: $0 [опции]"
    echo "Опции:"
    echo "  -u, --users       Вывести список пользователей и их домашних директорий"
    echo "  -p, --processes   Вывести список запущенных процессов"
    echo "  -l FILE, --log FILE   Перенаправить вывод в файл"
    echo "  -e FILE, --errors FILE   Перенаправить ошибки в файл"
    echo "  -h, --help        Показать эту справку"
}

# Переменные для хранения параметров
LOG_FILE=""
ERRORS_FILE=""
SHOW_USERS=false
SHOW_PROCESSES=false
SHOW_HELP=false

# Обработка аргументов командной строки
while [[ $# -gt 0 ]]; do
    case "$1" in
        -u|--users)
            SHOW_USERS=true
            shift
            ;;
        -p|--processes)
            SHOW_PROCESSES=true
            shift
            ;;
        -l|--log)
            LOG_FILE="$2"
            shift 2
            ;;
        -e|--errors)
            ERRORS_FILE="$2"
            shift 2
            ;;
        -h|--help)
            SHOW_HELP=true
            shift
            ;;
        *)
            echo "Ошибка: Неизвестный аргумент $1" >&2
            print_help
            exit 1
            ;;
    esac
done

# Перенаправление ошибок, если указано
if [[ -n "$ERRORS_FILE" ]]; then
    exec 2>"$ERRORS_FILE"
fi

# Перенаправление вывода, если указано
if [[ -n "$LOG_FILE" ]]; then
    exec >"$LOG_FILE"
fi

# Выполнение запрошенных действий
if $SHOW_HELP; then
    print_help
    exit 0
fi

if $SHOW_USERS; then
    print_users
fi

if $SHOW_PROCESSES; then
    print_processes
fi

exit 0
