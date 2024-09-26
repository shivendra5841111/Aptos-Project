module MyModule::GreenEnergyTrading {

    use aptos_framework::coin;
    use aptos_framework::signer;
    use aptos_framework::aptos_coin::{AptosCoin};

    struct EnergyListing has store, key {
        seller: address,
        energy_amount: u64,   // Amount of energy for sale (in kilowatt-hours, for example)
        price_per_unit: u64,  // Price per unit of energy
        is_sold: bool,
    }

    // Function to list energy for sale
    public fun list_energy_for_sale(seller: &signer, energy_amount: u64, price_per_unit: u64) {
        let listing = EnergyListing {
            seller: signer::address_of(seller),
            energy_amount,
            price_per_unit,
            is_sold: false,
        };
        move_to(seller, listing);
    }

    // Function to purchase listed energy
    public fun purchase_energy(buyer: &signer, seller: address, amount: u64) acquires EnergyListing {
        let listing = borrow_global_mut<EnergyListing>(seller);

        // Ensure the energy is not already sold
        assert!(!listing.is_sold, 1);

        // Calculate total price and transfer tokens from buyer to seller
        let total_price = listing.price_per_unit * amount;
        coin::transfer<AptosCoin>(buyer, listing.seller, total_price);

        // Mark energy as sold
        listing.is_sold = true;
    }
}
