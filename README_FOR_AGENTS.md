# 🤖 GUÍA PARA AGENTES IA

> **¡IMPORTANTE!** Cualquier agente que trabaje en este proyecto DEBE leer TODOS estos archivos antes de empezar

## 📚 LECTURA OBLIGATORIA (en este orden)

### 1️⃣ **Agents.md** - Especificaciones completas del proyecto
- **QUÉ HACER**: Entender completamente el proyecto OwnAutoCare
- **CONTIENE**: Arquitectura, tecnologías, modelo de datos, flujos de usuario
- **TIEMPO**: 5-7 minutos de lectura

### 2️⃣ **CURRENT_STATUS.md** - Estado actual del desarrollo
- **QUÉ HACER**: Saber exactamente dónde está el proyecto ahora
- **CONTIENE**: Lo que está hecho, lo que falta, problemas conocidos
- **TIEMPO**: 2-3 minutos de lectura

### 3️⃣ **NEXT_TASKS.md** - Roadmap priorizado de tareas
- **QUÉ HACER**: Elegir la tarea #1 pendiente y ejecutarla
- **CONTIENE**: Tareas específicas con criterios de completitud
- **TIEMPO**: 2-3 minutos de lectura

### 4️⃣ **SESSION_LOG.md** - Historial de lo que han hecho otros agentes
- **QUÉ HACER**: Entender el progreso y evitar repetir trabajo
- **CONTIENE**: Log detallado de cada sesión anterior
- **TIEMPO**: 3-5 minutos de lectura

## 🎯 PROTOCOLO DE TRABAJO

### ✅ ANTES de empezar cualquier tarea:
1. Lee los 4 archivos arriba EN ORDEN
2. Verifica que entiendes el contexto completo
3. Identifica la tarea #1 en `NEXT_TASKS.md`
4. Confirma con el usuario: "Voy a hacer la tarea X, ¿correcto?"

### 🔨 MIENTRAS trabajas:
- Haz SOLO una tarea por sesión
- Ejecuta la tarea COMPLETAMENTE (no dejes nada a medias)
- Comprueba que todo funciona antes de terminar
- Haz commits frecuentes con mensajes descriptivos

### 📝 AL TERMINAR tu sesión:
1. **Actualiza `CURRENT_STATUS.md`** con el nuevo estado
2. **Añade tu entrada a `SESSION_LOG.md`** usando el template
3. **Muestra una demo funcionando** de lo que completaste
4. **Confirma que todo compila sin errores**

## 🚫 REGLAS IMPORTANTES

### ❌ NO HACER:
- Empezar sin leer toda la documentación
- Hacer más de una tarea por sesión
- Cambiar la arquitectura sin discutir con el Product Owner
- Dejar código que no compila
- Inventar requisitos no especificados

### ✅ SÍ HACER:
- Seguir exactamente las specs de `Agents.md`
- Mantener Clean Architecture + DDD
- Escribir tests para todo el código
- Ser conservador con las decisiones técnicas
- Preguntar si algo no está claro

## 📋 TEMPLATE PARA EMPEZAR

```
👋 Hola, soy [NOMBRE_AGENTE]

✅ He leído:
- Agents.md (especificaciones completas)
- CURRENT_STATUS.md (estado actual)  
- NEXT_TASKS.md (roadmap priorizado)
- SESSION_LOG.md (historial de sesiones)

🎯 Voy a ejecutar: [TAREA #X de NEXT_TASKS.md]

¿Es correcto? ¿Algún cambio de prioridades?
```

## 🔄 FLUJO DE ROTACIÓN DE AGENTES

Cada nuevo agente puede empezar inmediatamente:
1. **Lee este archivo** (README_FOR_AGENTS.md)
2. **Sigue el protocolo** de arriba
3. **Confirma la tarea** con el Product Owner
4. **Ejecuta completamente** una tarea
5. **Documenta el progreso** y termina

---

**PRODUCT OWNER**: Para rotar agentes, simplemente comparte este archivo y diles que lean todo el contexto antes de empezar.
