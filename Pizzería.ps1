# Creamos el menú
function Menu{ 
    Write-Host "1) Pizza Vegetariana"
    Write-Host "2) Pizza Comun"
    Write-Host "0) Salir"
}

# Creamos un bucle que compare las posibilidades
do{
    Menu
    $pi = read-host "Seleccione una opción"
    switch ($pi){
        1{
            write-host "Escoja entre estos dos ingredientes"
            write-host "1) Tofu"
            Write-Host "2) Pimiento"
            $ingredientv = read-host "Seleccione una opción (Mozzarella y tomate ya incluidos)"
            if ($ingredientv -eq 1){
                write-host "Usted eligió la pizza de: Mozzarella, Tomate y Tofu"
            } else {
                write-host "Usted eligió la pizza de: Mozzarella, Tomate y Pimiento"  
            }
    
        }
        2{
            write-host "Escoja entre estos tres ingredientes"
            write-host "1) - Peperoni"
            write-host "2) - Jamón"
            write-host "3) - Salmón"
            $ingredientv = read-host "Seleccione una opción (Mozzarella y tomate ya incluidos)"
            if ($ingredientv -eq 1){
                write-host "Usted eligió la pizza de: Mozzarella, Tomate y Peperoni"
            } elseif ($ingredientv -eq 2) {
                write-host "Usted eligió la pizza de: Mozzarella, Tomate y Jamón"  
            } else {
                write-host "Usted eligió la pizza de: Mozzarella, Tomate y Salmón"
            }
        }
        0{
            write-host "Saliendo del menú..."
        }
        default{ 
            write-host "Opción no válida!"
        }
    } 
} while ($pi -ne 0)