<!-- Impact -->: High / Medium


<!-- Likelihood -->: High / Medium

### [M-1] Gas-Intensive Duplicate Check in `PuppyRaffle::enterRaffle` Potentially Prone to Denial-of-Service Attacks, Resulting in Increased Gas Costs for Participants When Entering the Raffle.

**Description**

The function `PuppyRaffle::enterRaffle` employs a loop to inspect the `players` array for duplicate entries. As the `players` array grows in size, the number of checks required for a new player increases proportionally. Consequently, participants who enter the raffle immediately upon commencement will incur significantly lower gas costs compared to those who join at a later stage. Each additional address introduced to the `players` array compounds the computational load of the loop. This differential in gas consumption between early and late entrants raises concerns of unequal participation costs and a potential susceptibility to denial-of-service attacks.

**Impact**

This vulnerability results in an unfair raffle experience for users, where participants who enter the raffle at different times face unequal gas costs. This inequality undermines the fairness of the raffle, potentially discouraging late entrants and favoring those who participate early.


**Proof of Concept:**

To substantiate the identified vulnerability, a test case was developed to demonstrate its practical implications. The test case, `testCheckForDuplicates`, exemplifies how the nested loop within the `enterRaffle` function creates a potential Denial-of-Service (DoS) vector attack. Furthermore, it highlights the disparity in gas fees between participants who enter the raffle early versus those who join later.

In the test case, the following actions are performed:

1. An array of 100 player addresses is generated and used to simulate the entry of the initial 100 participants into the raffle.

2. The gas consumption for these initial participants is measured, representing the gas cost incurred by early entrants.

3. An additional 5 players are introduced, symbolizing later entrants who join the raffle after its initiation.

4. The gas usage for these late entrants is measured to reflect the gas cost faced by participants who enter at a later stage.

The test case conclusively demonstrates that early participants encounter significantly lower gas costs compared to later entrants. The evidence provided through the test case underscores the vulnerability's impact on gas efficiency and fairness in the raffle, serving as a tangible illustration of the issue's real-world consequences.

testCheckForDuplicates:

```
function testCheckForDuplicates() public {
    vm.txGasPrice(1);

    uint256 playersNum = 100;
    address[] memory players = new address[](playersNum);

    for (uint256 i = 0; i < playersNum; i++) {
        players[i] = address(i);
    }

    // see how much gas it cost to enter
    uint256 gasStart = gasleft();
    puppyRaffle.enterRaffle{value: entranceFee * playersNum}(players);
    uint256 gasEnd = gasleft();
    uint256 gasUsedFirst = (gasStart - gasEnd) * tx.gasprice;
    console.log("Gas cost of the first 100 Players", gasUsedFirst);

    // enter 5 more players
    for (uint256 i = 0; i < playersNum; i++) {
        players[i] = address(i + playersNum);
    }

    // lets see how much gas it cost to enter now for later players
    gasStart = gasleft();
    puppyRaffle.enterRaffle{value: entranceFee * playersNum}(players);
    gasEnd = gasleft();
    uint256 gasUsedSecond = (gasStart - gasEnd) * tx.gasprice;
    console.log("Gas Cost of the 2nd 100 players", gasUsedSecond);

    assert(gasUsedFirst < gasUsedSecond);
//   Logs:
//     Gas cost of the first 100 Players 6252039
//     Gas Cost of the 2nd 100 players 18067748

}
```

**Recommendations / Mitigations**

To mitigate this vulnerability and improve gas efficiency, consider using a different data structure to store and track participants. One common approach is to use a mapping to keep track of participants' uniqueness. Here's an example of how you can refactor the code:

```solidity
contract PuppyRaffle {
    // Use a mapping to track participants
    mapping(address => bool) public isParticipant;

    function enterRaffle(address[] memory newPlayers) public payable {
        require(msg.value == entranceFee * newPlayers.length, "PuppyRaffle: Must send enough to enter raffle");

        for (uint256 i = 0; i < newPlayers.length; i++) {
            address player = newPlayers[i];

            // Check if the player is already a participant
            require(!isParticipant[player], "PuppyRaffle: Duplicate player");

            // Mark the player as a participant
            isParticipant[player] = true;
        }

        emit RaffleEnter(newPlayers);
    }
}
```

In this refactored code, a mapping called `isParticipant` is used to keep track of whether an address has already participated in the raffle. When a player enters the raffle, the code checks if the player is already a participant using the `isParticipant` mapping. If the player is not already a participant, they are marked as a participant, and the `isParticipant` mapping is updated.

This approach eliminates the need for nested loops to check for duplicates, making the code more efficient and secure against DoS attacks, as gas costs are now predictable and independent of the number of participants.