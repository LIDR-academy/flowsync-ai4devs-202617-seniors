# FlowSync

Gestión de tareas en equipo. Monorepo con **AdonisJS 7 + SQLite** en `backend/` y **React 19 + Vite** en `frontend/`.

Este es el proyecto sobre el que trabajas en el Módulo 3. Léelo entero antes de empezar: además de cómo levantarlo, aquí está **el ejercicio y cómo se entrega**.

## Arrancarlo

No hay `package.json` en la raíz. Los comandos de `npm` se ejecutan dentro de `backend/` y de `frontend/`, y el `Makefile` de la raíz ya lo hace por ti.

```bash
make setup   # solo la primera vez: instala deps, crea los .env, genera la APP_KEY y migra
make start   # levanta backend (:3333) y frontend (:5173) a la vez
make help    # lista todos los targets
```

`make start` arranca los dos servidores juntos; `Ctrl-C` los para, y si uno se cae se lleva al otro por delante. El frontend apunta al backend por defecto; para cambiarlo, ajusta `VITE_API_URL` en `frontend/.env`.

> Requisitos: Node.js 20.19+ (lo pide OpenSpec, que instalas en el prework) y GNU Make. En Windows, desde WSL y con el repo clonado dentro del sistema de ficheros de Linux.

## Qué hay ya construido

- **El vertical de cuentas y acceso, de punta a punta**: registro, inicio de sesión, sesión y perfil, con su API y sus pantallas. Es la superficie del ejercicio.
- **El PRD y el backlog del equipo**, en `docs/`. No los necesitas para el ejercicio; los usa el directo.
- **La capa de agente** de la raíz (`CLAUDE.md`, `AGENTS.md`, `.claude/`, `.mcp.json`), que es parte del material y no un accesorio.

---

# El ejercicio

**Se hace antes del directo.** Son unos 45 minutos y hay que ponerles un reloj.

## Cómo funciona este módulo

Tres momentos, y conviene que los sepas antes de empezar:

1. **Lo intentas tú**, aquí, sobre este proyecto. Entregas lo que te salga, con lo que tenga.
2. **Lo ves resuelto en el directo.** El mentor hace este mismo ejercicio sobre este mismo proyecto y sobre la misma superficie. Si no te salió, ahí ves que se puede y cómo.
3. **Lo replicas después**, con los prompts del mentor, que te llegan por escrito.

Por eso la entrega a medias no es un problema: **el paso 1 no se puntúa por completarlo**. Y por eso conviene mirar el directo sin teclear, porque lo vas a repetir con calma luego.

> ⚠️ **En el paso 3 no esperes salidas idénticas.** El agente no es determinista: con el mismo prompt y el mismo código cambian la redacción, el orden y hasta cuántos requisitos escribe. Lo que se repite es **la forma**, no el texto.

## Parte A: la spec, con reloj

Con un agente, escribe **la spec de lo que el sistema hace hoy** en el vertical de cuentas y acceso, y déjala en `docs/spec-viva/<tus-iniciales>.md`, no en el chat. La carpeta no existe todavía: la crea tu archivo.

**Una sola mitad.** Esa superficie tiene dos capas: lo que pasa por la API y lo que se ve en pantalla. **Elige una, no las dos.** Cabe hacer las dos; lo que no cabe es comprobarlas después, que es donde está el ejercicio.

**Para esto no necesitas OpenSpec, y no lo inicialices aquí.** No se lanza ningún comando: se lee el código que ya está en el repo y se escribe un archivo de texto con el formato de una spec viva. El `openspec init` sobre este proyecto llega en el directo.

**El formato no es negociable:**

- Arriba, un `## Purpose` de una o dos frases: para qué existe esta capability.
- Debajo, `## Requirements`, y colgando de él `### Requirement:` en los que el sistema **SHALL** hacer algo.
- Bajo cada requisito, al menos un `#### Scenario:` de cuatro almohadillas, con dos viñetas: `- **WHEN**` y `- **THEN**`. No hay casilla para el `GIVEN`: la precondición va dentro del `WHEN`.
- En castellano, salvo las mayúsculas de la RFC.

**Y tres reglas duras:**

1. **Nada de `ADDED`, `MODIFIED` ni `REMOVED`.** Eso es el vocabulario de un delta, y esto no es un delta: es la verdad actual del sistema.
2. **Solo comportamiento observable desde fuera.** Ni un nombre de clase, ni un nombre de archivo, ni una ruta de código. Si vas por la API, observable es la petición y la respuesta. Si vas por la pantalla, observable es lo que una persona ve y puede hacer.
3. **No toques el código.** Ni siquiera para arreglar lo que encuentres, y sobre todo para eso: lo que encuentres es material de la parte B.

> ⚠️ **Cuando suene el reloj, para. Aunque esté a medias.** Una spec en la que comprobaste seis de los requisitos que escribiste y dejaste dos a medias **es información**: dice hasta dónde llegaste. Una spec completada de memoria diez minutos después es ruido con formato, y encima es indistinguible de la buena.

## Parte B: las tres listas

Debajo de la spec, en el mismo archivo. **Esta parte no se puede fallar**, y es la que hay que traer sí o sí.

1. **Cuántos requisitos escribió el agente, y cuántos comprobaste tú abriendo el código.** Los dos números, tal cual salieron. Comprobar significa haber ido a mirar; leer el requisito y que suene razonable no cuenta.
2. **Las incoherencias que aparecieron al escribirla**, una línea cada una y con dónde se ve.
3. **Lo que no supiste decidir si era un bug o el contrato**, y en una frase, qué dos lecturas se contradecían. Esta es la que importa.

---

# Cómo se entrega

**Es un pull request desde tu fork.** Cinco pasos.

### 1. Forkea este repositorio

Con el botón **Fork** de arriba. Sobre un clon directo no tienes permiso de escritura, y aquí vas a crear una rama y commitear.

```bash
git clone git@github.com:<tu-usuario>/flowsync-ai4devs.git
cd flowsync-ai4devs
git remote add upstream git@github.com:LIDR-academy/flowsync-ai4devs.git
git fetch upstream
git checkout -b s3/start upstream/s3/start
```

> 📌 Si te sale `Permission denied (publickey)`, es SSH y no el fork. La guía oficial está en `docs.github.com/es/authentication/connecting-to-github-with-ssh`.

### 2. Crea tu rama

```bash
git checkout -b spec-viva-<tus-iniciales>
```

### 3. Haz el ejercicio

Tu archivo va en `docs/spec-viva/`, con los requisitos de la Parte A y las tres listas de la Parte B.

### 4. Rellena `prompts.md`

Está en la raíz, con la plantilla puesta. **Es obligatorio y es la mitad de lo que se revisa**: lo que se mira no es solo tu resultado, es cómo lo pediste. Un prompt por bloque, con el modelo y la herramienta que usaste, incluidos los que no funcionaron.

### 5. Abre el pull request

Contra este repositorio, no contra tu fork. Con tu rama empujada, GitHub te ofrece el botón arriba.

```bash
git add docs/spec-viva prompts.md
git commit -m "spec viva: <la mitad que elegiste> + prompts"
git push -u origin spec-viva-<tus-iniciales>
```

## El plazo

**Antes del directo.** Lo que llegue a tiempo recibe feedback de tu TA antes de la sesión, que es el momento en que te sirve. Lo que llegue después **se marca como recibido pero no se revisa**: el feedback existe para que llegues al directo sabiendo dónde fallaste, y después de la sesión ya no puede hacer eso.

## Antes de conectarte, comprueba

- [ ] Estás en tu **fork**, en tu rama, y `git push` funciona.
- [ ] El proyecto levanta entero y puedes iniciar sesión en la interfaz.
- [ ] Existe tu archivo en `docs/spec-viva/`, con la spec y las tres listas.
- [ ] `prompts.md` está relleno, con modelo y herramienta en cada bloque.
- [ ] El pull request está abierto.

> Las instrucciones completas de prework (instalar OpenSpec, sandbox y priming) están en el asíncrono del curso.
