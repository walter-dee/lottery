# STX Lottery Smart Contract

A secure and transparent lottery system built on Stacks blockchain using Clarity smart contracts.

## Features

- **Secure Ticket Purchasing**: Users can buy tickets using STX tokens
- **Duplicate Prevention**: Each address can only purchase one ticket per round
- **Transparent Prize Pool**: All funds are held by the contract
- **Admin Controls**: Controlled lottery rounds with owner-only functions
- **Automated Payouts**: Winners receive prizes automatically
- **Fair Selection**: Uses round-based randomization for winner selection

## Contract Functions

### Public Functions

```clarity
(buy-ticket) -> Allows users to purchase a lottery ticket
(close-lottery) -> Admin function to close ticket sales
(draw-winner) -> Admin function to select and pay winner
```

### Read-Only Functions

```clarity
(get-lottery-info) -> Returns complete lottery state
(get-round) -> Returns current round number
(get-players) -> Returns list of current players
(lottery-open?) -> Checks if lottery is accepting tickets
```

## Usage

1. Deploy the contract to Stacks blockchain
2. Users can purchase tickets by calling `buy-ticket`
3. Admin closes lottery when ready using `close-lottery`
4. Admin draws winner using `draw-winner`
5. Winner automatically receives prize in STX

## Technical Details

- **Ticket Price**: 10 STX
- **Maximum Players**: 100 per round
- **State Management**: Uses Clarity data vars and maps
- **Security**: Contract-based fund management
- **Error Handling**: Comprehensive error codes and assertions

## Development

```bash
# Clone the repository
git clone https://github.com/yourusername/stx-lottery

# Run tests (requires clarinet)
clarinet test

# Deploy to testnet
clarinet deploy --network testnet
```

## License

MIT License

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## Security

This contract has not been audited. Use at your own risk.

---
Built with ❤️ using Clarity and Stacks blockchain.
