REALISTIC SHOVEL 0.2.4 - DESPLAZAMIENTO DE MATERIALES - versión de prueba
========================================
Requiere Varia Addons (variaAddons). No requiere otros mods.
No modifica los archivos de Steam Workshop en disco, POWERDIGGER, las otras
palas ni los materiales globales. Registra una acción interna exclusiva,
REALISTIC_SHOVEL_DIG, sin aparición natural. Una vez comprobada su presencia
por la API, cambia el ID de la carta permanente existente de la pala común
(tag shovel). También elimina virtualmente el bucle original action_count
sin inicializar, si el código coincide con la versión examinada.

INSTALACIÓN
1. Cerrar Noita. Hacer una copia de save00 antes de cualquier prueba.
2. Borrar la carpeta mods/realistic_shovel anterior por completo.
3. Extraer la carpeta realistic_shovel en Steam/steamapps/common/Noita/mods.
4. Activarla debajo de Varia Addons, preferentemente justo antes de DYG
   Remastered, Infinity y Spells Evolutions (mantener su orden relativo).
5. Reiniciar Noita. Se puede probar con la pala común de una partida guardada.
   No es necesario Conjurer:RE ni empezar una nueva partida.

COMPORTAMIENTO / DIAGNÓSTICO
Mantiene el proyectil y las conversiones de 0.2.2: sand_static -> soil;
sand_static_rainforest -> soil; snow_static -> snow; coal_static -> coal.
Nuevas conversiones: sand_static_bright y sand_static_red -> soil (9x9);
rock_static_fungal -> fungisoil (5x5); rock_static_wet -> sand_static (3x3).
La roca húmeda se convierte al final de la pasada; requiere otro disparo
para volver ese suelo tierra suelta. Los tamaños limitan el área por disparo,
no garantizan una velocidad exacta. No cambia la dureza global de ningún material.
Conserva un colector invisible y local de 9x9, activo durante 4 fotogramas.
Usa MaterialSuckerComponent (polvos no estáticos con tag [sand_ground])
y MaterialInventoryComponent con on_death_spill, como Powder Vacuum Field.
La tierra suelta recogida se expulsa cerca del jugador, hacia un lado libre.
No hay generación manual de materia. No se toca la roca común, roca congelada, roca densa ni metales sólidos.
La roca húmeda es la excepción solicitada.
El colector de suelo no filtra por ID exacto: desplaza los polvos de terreno
con [sand_ground] sin convertirlos, incluido el fango. No existe conversión
mud -> soil en el mod. El motor puede producir esa reacción después del vertido.
Nuevos colectores separados, mismos 9x9 y cuatro fotogramas:
- líquidos dinámicos (material_type=0), sin filtro de tag;
- otros polvos (material_type=1, [sand_other]), incluido carbón.
El segundo también puede desplazar pólvora, polvos minerales y otros polvos
con esa etiqueta. No rompe roca ni metales sólidos, ni da oro o salud al jugador.
Ambos se pueden desactivar por separado en config.lua.
Los tres inventarios tienen do_reactions=0; las reacciones del mundo siguen
activas tras expulsar material. No se crean materiales ni se cambia su ID.
Los líquidos peligrosos pueden caer cerca del personaje, como los polvos.
El radio no aumenta; con tres colectores puede aumentar el rendimiento de
extracción y el coste de CPU, aún sin medir en juego.
La arcilla de mods no se convierte sin identificar un equivalente apropiado.
La extracción en tierra común ha sido comprobada por el usuario en 0.2.2.
Las conversiones 0.2.3 se mantienen; líquidos y otros polvos nuevos requieren pruebas en juego.
En logger.txt buscar 'Collector ... main=mud; native amount=...; spill ...'
o main=water / oil / coal. main es el material mayoritario antes del vertido.
Pruebas: suelo horizontal, pared, techo y roca/metal; observar si se vacía el
hueco y si aparecen montículos reales cerca. Comparar con la versión 0.2.2. Probar fango aislado, agua, aceite y carbón.
El registro muestra 8 llamadas de conversión, no el número de píxeles.
No quitar mods ni iniciar una partida nueva; mantener orden y copia de save00.

DESINSTALACIÓN / RESTAURACIÓN
Antes de desactivar el mod, cerrar Noita y editar realistic_shovel/config.lua:
 REALISTIC_SHOVEL_RESTORE = true
Iniciar Noita con el mod todavía activado, cargar la partida y tener la pala
común en el inventario o cerca. Esperar a que se restaure la carta permanente.
Guardar y cerrar; recién entonces desactivar y quitar el mod. Si hay palas
migradas en otras regiones, deben cargarse y restaurarse también antes de
retirar el mod, o usar una copia de seguridad anterior a la instalación.
Para volver al comportamiento modificado, cambiar config.lua a false.

VALIDACIÓN
Sintaxis Lua 5.4 y XML comprobadas fuera del juego. El motor de Noita no se
ha ejecutado; la captura, filtro, expulsión y conservación siguen en prueba.
