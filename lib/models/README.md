# Modelos de Datos - Shopping List

Este directorio contiene todos los modelos de datos (DTOs) para la aplicación de lista de compras compartida.

## 📋 Modelos Principales

### `HouseMember`
Representa un miembro/participante de la casa compartida.
- `id`: String - Identificador único
- `name`: String - Nombre del miembro
- `color`: Color (getter) - Color generado automáticamente basado en el ID

**Nota:** El color NO viene del backend, se genera localmente en Flutter de forma consistente usando el hash del ID del miembro.

---

### `ShoppingItem`
Representa un producto en la lista de compras.
- `id`: String - Identificador único
- `name`: String - Nombre del producto
- `isPurchased`: bool - Si ya fue comprado
- `price`: double? - Precio (null si no está comprado)
- `purchasedBy`: HouseMember? - Quién lo compró
- `purchasedAt`: DateTime? - Cuándo fue comprado
- `createdAt`: DateTime - Cuándo se agregó a la lista

---

### `ExpenseSummary`
Resumen de gastos por miembro (calculado en backend).
- `memberId`: String
- `memberName`: String
- `totalSpent`: double - Total gastado por el miembro
- `balance`: double - Balance vs promedio (+ le deben, - debe)
- `itemsPurchased`: int - Cantidad de productos comprados

---

### `Transfer`
Transferencia sugerida para balancear gastos.
- `fromMemberId`: String - Quien debe pagar
- `fromMemberName`: String
- `toMemberId`: String - Quien debe recibir
- `toMemberName`: String
- `amount`: double - Monto a transferir

---

## 📤 Requests (Frontend → Backend)

### `AddProductRequest`
Para agregar un nuevo producto a la lista.
```dart
{
  "name": "Leche",
  "apartmentId": "apt123" // opcional
}
```

### `MarkPurchasedRequest`
Para marcar un producto como comprado.
```dart
{
  "productId": "prod123",
  "price": 3.50,
  "purchasedById": "user456"
}
```

---

## 📥 Responses (Backend → Frontend)

### `ShoppingListResponse`
Respuesta completa con toda la información de la pantalla.

```dart
{
  "items": [ShoppingItem],           // Lista de productos
  "members": [HouseMember],          // Miembros de la casa
  "totalExpenses": 39.00,            // Gasto total
  "averageExpensePerMember": 9.75,   // Promedio por persona
  "expensesSummary": [ExpenseSummary], // Resumen por miembro
  "suggestedTransfers": [Transfer],   // Transferencias sugeridas
  "currentUserId": "user123"         // Usuario actual
}
```

---

## 🔄 Flujo de Datos

### GET - Cargar datos de la pantalla
**Endpoint sugerido:** `GET /api/shopping-list/{apartmentId}`

**Response:** `ShoppingListResponse`

El backend debe calcular:
- Gasto total
- Promedio por persona
- Balance de cada miembro
- Transferencias óptimas sugeridas

---

### POST - Agregar producto
**Endpoint sugerido:** `POST /api/shopping-list/items`

**Request:** `AddProductRequest`
```json
{
  "name": "Pan integral",
  "apartmentId": "apt123"
}
```

**Response:** `ShoppingItem` (el producto creado)

---

### PUT - Marcar como comprado
**Endpoint sugerido:** `PUT /api/shopping-list/items/{itemId}/purchase`

**Request:** `MarkPurchasedRequest`
```json
{
  "productId": "item456",
  "price": 8.50,
  "purchasedById": "user123"
}
```

**Response:** `ShoppingItem` (el producto actualizado)

Alternativamente, puede devolver `ShoppingListResponse` completo para actualizar toda la pantalla con los cálculos recalculados.

---

## 💡 Notas para el Backend

1. **Colores de miembros:** Enviar como strings hexadecimales (ej: "#2196F3")

2. **Cálculos:** El backend debe calcular:
   - Total gastado
   - Promedio por persona
   - Balance individual (gasto - promedio)
   - Transferencias óptimas usando algoritmo greedy

3. **Fechas:** Usar formato ISO 8601 (ej: "2025-10-13T14:30:00Z")

4. **Algoritmo de transferencias sugeridas:**
   - Separar deudores y acreedores
   - Calcular transferencias mínimas necesarias
   - Ejemplo: Si Ana gastó €20.80 y el promedio es €9.75, tiene crédito de €11.05
     - Carlos debe €0.75 → Carlos paga a Ana €0.75
     - María debe €7.25 → María paga a Ana €7.25
     - Luis debe €3.05 → Luis paga a Ana €3.05

5. **Usuario actual:** Enviar el ID del usuario autenticado para destacarlo en la UI

