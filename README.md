# 📦 Subasta Smart Contract

Este proyecto es un contrato inteligente escrito en Solidity que permite gestionar una **subasta descentralizada** en la blockchain de Ethereum. Los usuarios pueden hacer ofertas, aumentar el tiempo de la subasta si hay ofertas en los últimos minutos y recuperar depósitos no ganadores.

---

## 📜 Descripción

La subasta funciona de la siguiente manera:

- La subasta tiene una duración inicial de **7 días**.
- La oferta mínima inicial es de **0.01 ETH**.
- Cada nueva oferta debe superar a la anterior en al menos un **5%**.
- Si alguien realiza una oferta cuando quedan menos de **10 minutos** para el cierre, se extiende la subasta por **10 minutos adicionales**.
- Se pueden realizar reembolsos parciales o devolución de depósitos al finalizar.

---

## 📝 Funcionalidades

### 📌 Bid()
Permite a un usuario realizar una oferta.  
**Requisitos:**
- La oferta debe superar en al menos un 5% la última oferta.
- Solo se puede ejecutar mientras la subasta esté activa.

### 📌 showWinner()
Devuelve la dirección del usuario que realizó la oferta más alta.

### 📌 showBids()
Devuelve un array con todas las ofertas realizadas.

### 📌 retDeposit()
Función que **solo puede ejecutar el owner** cuando la subasta termina.  
Devuelve el 98% de lo depositado a todos los postores y transfiere el saldo restante al owner.

### 📌 partialRefund()
Permite a un usuario recuperar todo su dinero excepto su última oferta mientras la subasta siga activa.

---

## ⚙️ Estructuras de Datos

```solidity
struct bid {
  address bidder;
  uint amount;
}

struct MyBids {
  uint256 last;
  uint256 accumulated;
}


