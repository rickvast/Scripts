﻿# Función para mostrar el menú
function Menu {
    Clear-Host
    Write-Host "=== MENU DE GRUPOS ==="
    Write-Host "1. Listar grupos"
    Write-Host "2. Ver miembros de un grupo"
    Write-Host "3. Crear grupo"
    Write-Host "4. Eliminar grupo"
    Write-Host "5. Agregar miembro a un grupo"
    Write-Host "6. Eliminar miembro de un grupo"
    Write-Host "0. Salir"
    Write-Host "======================="
}

# Bucle principal del menú
do {
    Menu
    $opcion = Read-Host "Seleccione una opción"

    switch ($opcion) {
        1 {
            Write-Host "Listando grupos..."
            Get-LocalGroup | Select-Object Name | Out-Host
            pause
        }
        2 {
            Get-LocalGroup | Select-Object Name | Out-Host
            $grupo = Read-Host "Ingrese el nombre del grupo"
            Write-Host "Miembros del grupo '$grupo':"
            Get-LocalGroupMember -Group $grupo | Select-Object Name | Out-Host
            pause
        }
        3 {
            $grupo = Read-Host "Ingrese el nombre del nuevo grupo"
            New-LocalGroup -Name $grupo
            Write-Host "Grupo '$grupo' creado con éxito"
            pause
        }
        4 {
            $grupo = Read-Host "Ingrese el nombre del grupo a eliminar"
            Remove-LocalGroup -Name $grupo
            Write-Host "Grupo '$grupo' eliminado con éxito"
            pause
        }
        5 {
            $grupo = Read-Host "Ingrese el nombre del grupo"
            $usuario = Read-Host "Ingrese el nombre del usuario a agregar"
            Add-LocalGroupMember -Group $grupo -Member $usuario
            Write-Host "Usuario '$usuario' agregado al grupo '$grupo' con éxito"
            pause
        }
        6 {
            $grupo = Read-Host "Ingrese el nombre del grupo"
            $usuario = Read-Host "Ingrese el nombre del usuario a eliminar"
            Remove-LocalGroupMember -Group $grupo -Member $usuario
            Write-Host "Usuario '$usuario' eliminado del grupo '$grupo' con éxito"
            pause
        }
        0 {
            Write-Host "Saliendo..."
            break
        }
        default {
            Write-Host "Opción no válida"
            pause
        }
    }
} while ($opcion -ne 0)
