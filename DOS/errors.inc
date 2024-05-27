; =====================================
; Error codes
; =====================================
ERR_NO_ERROR		        EQU	0x00	; (00) - нет ошибок
ERR_INVALID_FUNCTION	    EQU	0x01	; (01) - неверный номер функции
ERR_INVALID_DRIVE	        EQU	0x02	; (02) - неправильный номер устройства
ERR_FILE_NOT_FOUND	        EQU	0x03	; (03) - файл не обнаружен
ERR_PATH_NOT_FOUND	        EQU	0x04	; (04) - неверный путь
ERR_INVALID_HANDLE	        EQU	0x05	; (05) - несуществующий файловый манипулятор
ERR_NO_HANDLES		        EQU	0x06	; (06) - нет свободного файлового манипулятора
ERR_FILE_EXISTS		        EQU	0x07	; (07) - файл существует
ERR_READONLY		        EQU	0x08	; (08) - файл только для чтения
ERR_ROOT_OVERFLOW	        EQU	0x09	; (09) - переполнение ROOT	; (корневого каталога)
ERR_DISK_FULL		        EQU	0x0A	; (10) - нет свободного места на диске
ERR_DIR_NOT_EMPTY	        EQU	0x0B	; (11) - каталог не пуст
ERR_CURRENT_DIR		        EQU	0x0C	; (12) - попытка удалить текущий каталог
ERR_UNKNOWN_FORMAT	        EQU	0x0D	; (13) - неизвестный формат
ERR_INVALID_ACCESS	        EQU	0x0E	; (14) - невозможная операция
ERR_DIR_EXISTS		        EQU	0x0F	; (15) - каталог уже есть
ERR_INVALID_NAME	        EQU	0x10	; (16) - неверное имя
ERR_INVALID_EXE		        EQU	0x11	; (17) - неправильный EXE-файл
ERR_UNKNOWN_EXE		        EQU	0x12	; (18) - не поддерживаемая версия EXE-файла
ERR_ACCESS_DENIED	        EQU	0x13	; (19) - ресурс не доступен
;       
ERR_NOT_READY		        EQU	0x14	; (20) - нет готовности
ERR_SEEK_ERROR		        EQU	0x15	; (21) - ошибка позиционирования
ERR_SECTOR_NOT_FOUND	    EQU	0x16	; (22) - сектор не найден
ERR_CRC_ERROR		        EQU	0x17	; (23) - ошибка CRC
ERR_WRITE_PROTECT	        EQU	0x18	; (24) - защита записи
ERR_READ_ERROR		        EQU	0x19	; (25) - ошибка чтения
ERR_WRITE_ERROR		        EQU	0x1A	; (26) - ошибка записи
ERR_GENERAL_FAILURE	        EQU	0x1B	; (27) - общая ошибка
ERR_RESERVED_28		        EQU	0x1C	; (28) - зарезервирован
ERR_RESERVED_29		        EQU	0x1D	; (29) - зарезервирован
;
ERR_NOT_ENOUGH_MEMORY	    EQU	0x1E	; (30) - недостаточно памяти
ERR_INVALID_MEMORY_HND	    EQU	0x1F	; (31) - несуществующий блок памяти
ERR_RESERVED_32		        EQU	0x20	; (32) - зарезервирова
;
ERR_INVALID_VIDEO_MODE	    EQU	0x30	; (48) - зарезервирова
