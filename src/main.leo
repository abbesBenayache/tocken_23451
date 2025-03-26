program token_22541.aleo {
    // aleo100e4auwg4ltwwft26qdz5zxsp3lf9zcvrj8qh38uyk872pu0pcgqfpvdus
    mapping balance: address => u64;

    record Token {
        owner: address,
        balance: u64,
    }

    transition mint(amount: u64) -> Token {
        return Token {
            owner: self.caller,
            balance: amount,
        };
    }

    transition transfer_private(receiver: address, amount: u64, input: Token) -> (Token, Token) {
        let remaining: u64 = input.balance - amount;

        let caller_token: Token = Token {
            owner: self.caller,
            balance: remaining,
        };

        let receiver_token: Token = Token {
            owner: receiver,
            balance: amount,
        };

        return (caller_token, receiver_token);
    }

    transition transfer_private_to_public(receiver: address, amount: u64, input: Token) -> Token {
        let remaining: u64 = input.balance - amount;

        let caller_token: Token = Token {
            owner: self.caller,
            balance: remaining,
        };

        finalize_transfer_private_to_public(receiver, amount);
        return caller_token;
    }

    finalize transfer_private_to_public(receiver: address, amount: u64) {
        let prev: u64 = balance.get_or_use(receiver, 0u64);
        balance.set(receiver, prev + amount);
    }

    transition transfer_public_to_private(receiver: address, amount: u64) -> Token {
        finalize_transfer_public_to_private(self.caller, amount);
        return Token {
            owner: receiver,
            balance: amount,
        };
    }

    finalize transfer_public_to_private(caller: address, amount: u64) {
        let prev: u64 = balance.get(caller);
        balance.set(caller, prev - amount);
    }
}
