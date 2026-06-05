# Guía de capturas de pantalla

Toma estas capturas mientras ejecutas el proyecto y guárdalas en `docs/screenshots/`.
Cada una refuerza una competencia distinta ante un reclutador.

## En IBM Cloud Schematics

1. `01-schematics-workspace.png` — El workspace creado, mostrando que está conectado a tu repo de GitHub.
2. `02-schematics-variables.png` — La pestaña de Variables con los valores configurados (oculta cualquier dato sensible).
3. `03-schematics-plan.png` — La salida del "Generate plan" mostrando los recursos que se van a crear.
4. `04-schematics-apply.png` — La ejecución del "Apply plan" completada con éxito (estado verde).

## En la consola de IBM Cloud (VPC Infrastructure)

5. `05-vpc-overview.png` — La VPC con sus dos subnets en zonas distintas.
6. `06-instances.png` — Las dos VSI (web-1 y web-2) corriendo, cada una en su zona.
7. `07-load-balancer.png` — El Load Balancer mostrando los dos miembros del pool en estado "healthy".
8. `08-backup-policy.png` — La política de backup con su plan diario activo.

## Prueba de funcionamiento

9. `09-browser-web1.png` — El navegador apuntando al hostname del LB, mostrando "Servidor: ha-demo-web-1".
10. `10-browser-web2.png` — Recarga (o varias recargas) mostrando "Servidor: ha-demo-web-2", lo que demuestra que el balanceo funciona.

## Limpieza

11. `11-destroy.png` — El "Destroy resources" completado, demostrando que sabes gestionar el ciclo de vida completo y controlar costos.
