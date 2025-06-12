/ SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

// Se deben utilizar modificadores cuando sea conveniente.
// El contrato debe ser seguro y robusto. Manejando adecuadamente los errores y las posibles situaciones excepcionales.
// Se deben utilizar eventos para comunicar los cambios de estado de la subasta a los participantes.
// documentar
// Los participantes pueden retirar de su depósito el importe por encima de su última oferta durante el desarrollo de la subasta.
 contract Subasta {

    struct Bid {
        address bidder;
        uint256 amount;
    }

    struct MyBids {
        uint256 last;
        uint256 accumulated;
    }

    Bid[] public bids;

    mapping(address => MyBids) public myBids;

    uint256 public endDate;
    uint256 public initialValue;
    address public owner;

    event NewOffer(address bider, uint256 amount);
    event AuctionEnded();    
    // para cumplir que debemos marcar con eventos los cambios de estados de la susbasta
    event AuctionStarted();

    constructor() {
        endDate = block.timestamp + 7 days;
        initialValue = 1 ether;
        owner = msg.sender;
    }

    modifier whenActive() {
        require(block.timestamp < endDate, "not active");
        _;
    }

    modifier whenNotActive() {
        require(block.timestamp > endDate, "Auction Running");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Solo el propietario");
        _;
    }

    // Subasta activa
    // 5% + que la anterior
    // se deposita y se guarda oferta y ofertante
    // emitir NewOffer cuando hay una nueva oferta
    // Si falta menos de 10 minutos para terminar haremos timelimit+10min
    function bid() external payable whenActive {

        uint256 bidQuantity = bids.length;
        uint256 minValue = bidQuantity == 0 ? initialValue : bids[bidQuantity-1].amount;

        require((minValue*105/100) < msg.value, "insufient funds");

        if((block.timestamp + 10 minutes) > endDate) {
            endDate += 10 minutes;
        }

        myBids[msg.sender].last = msg.value;
        myBids[msg.sender].accumulated += msg.value;
        
        bids.push(Bid(msg.sender, msg.value));

        emit NewOffer(msg.sender, msg.value); 
    }

    // Muestra ofertante y oferta
    function showWiner() external view returns (address) {
        uint256 bidQuantity = bids.length;
        return bids[bidQuantity-1].bidder;
    }

    // Muestra lista de ofertantes y ofertas
    function showBids() external view returns (Bid[] memory) {
        return bids;
    }

    // Al finalizar devuelve depósitos - 2%
    // Finaliza subasta
    // Emite AuctionEnded al finalizar subasta
    function retDeposit() external whenNotActive onlyOwner {

        uint256 bidQuantity = bids.length;
        uint256 value;
        address payable to;

        for(uint256 i=0; i < bidQuantity; i++) {
            to = payable (bids[i].bidder);
            value = myBids[to].accumulated;
            value = value * 98 / 100;
            if (value > 0) {
                myBids[to].accumulated = 0;
                to.transfer(value); // call
            }
        }
        value = address(this).balance;
        to = payable(msg.sender);
        to.transfer(value);

        emit AuctionStarted();
    }

    //Durante la subasta,=> isActive
    //los participantes pueden retirar el importe por encima de su última oferta válida.
    function partialRefund() external whenActive {
        // unicamente puede sacarlo quien le corresponde
        uint256 value = myBids[msg.sender].accumulated - myBids[msg.sender].last;
        address payable to = payable(msg.sender);
        to.transfer(value);
    }
}