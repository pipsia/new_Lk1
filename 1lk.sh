#!/bin/bash
 
# Справка
show_help() {
    echo "  -u, --users       Выводит перечень пользователей и их домашних директорий"
    echo "  -p, --processes   Выводит перечень запущенных процессов"
    echo "  -h, --help        Выводит справку"
    echo "  -l, --log PATH    Замещает вывод на экран выводом в файл по заданному пути PATH"
    echo "  -e, --errors PATH Замещает вывод ошибок из потока stderr в файл по заданному пути PATH"
}
 
# Пользователи
list_users() {
    awk -F: '$3>=1000 { print $1 " " $6 }' /etc/passwd | sort
}
 
# Процессы
list_processes() {
    ps -e -o pid,comm,start | sort -n
}
 
# Проверка доступа к пути
check_path() {
    local path="$1"
    if [ ! -w "$path" ]; then
        echo "Ошибка: Нет доступа для записи в $path" >&2
        exit 1
    fi
}
 
# Основная логика скрипта
main() {
    local log_file=""
    local error_file=""
 
    # Обработка аргументов
    while getopts ":upl:e:h-:" opt; do
        case ${opt} in
            u )
                list_users
                ;;
            p )
                list_processes
                ;;
            l )
                log_file="$OPTARG"
                check_path "$log_file"
                ;;
            e )
                error_file="$OPTARG"
                check_path "$error_file"
                ;;
            h )
                show_help
                exit 0
                ;;
            - )
                case $OPTARG in
                    users )
                        list_users
                        ;;
                    processes )
                        list_processes
                        ;;
                    log )
                        log_file="${!OPTIND}"; OPTIND=$(( OPTIND + 1 ))
                        check_path "$log_file"
                        ;;
                    errors )
                        error_file="${!OPTIND}"; OPTIND=$(( OPTIND + 1 ))
                        check_path "$error_file"
                        ;;
                    help )
                        show_help
                        exit 0
                        ;;
                    * )
                        echo "Неизвестный аргумент --$OPTARG" >&2
                        show_help
                        exit 1
                        ;;
                esac
                ;;
            \? )
                echo "Неизвестный аргумент -$OPTARG" >&2
                show_help
                exit 1
                ;;
            : )
                echo "Аргумент -$OPTARG требует значение" >&2
                show_help
                exit 1
                ;;
        esac
    done
 
    # Перенаправление вывода в файл, если указано
    echo "Лог-файл: $log_file" >&2
    if [ -n "$log_file" ]; then
        exec > "$log_file"
    fi
 
    # Перенаправление ошибок в файл, если указано
    if [ -n "$error_file" ]; then
        exec 2> "$error_file"
    fi
}
 
# Запуск основной логики
main "$@"
