# donk_truckgunplug

A FiveM script that allows players to interact with garbage trucks using third eye targeting to access gun-related functionality.

## 📋 Requirements

### Essential Dependencies
- **ox_inventory** - Required for inventory management
- **ox_target** - Required for third eye targeting system
- **ox_lib** - Required for UI and utility functions
- **oxmysql** - Required for database operations

### Required Asset
- **Garbage Truck Model** - Must be purchased from [VoodooCustom Tebex Store](https://voodoocustom.tebex.io/package/5236445)
  - This script will **NOT** work without this specific model
  - Purchase is mandatory for functionality

### Optional (For Discord Role Whitelisting)
- **donk_api** - Required only if you want to restrict access to specific Discord roles

## 🚀 Installation

1. **Download Dependencies**
   - Install ox_inventory
   - Install ox_target  
   - Install ox_lib
   - Install oxmysql

2. **Purchase Required Asset**
   - Visit [VoodooCustom Tebex Store](https://voodoocustom.tebex.io/package/5236445)
   - Purchase the required garbage truck model
   - Follow the provided installation instructions for the model

3. **Install the Script**
   - Download `donk_truckgunplug`
   - Place it in your server's `resources` folder
   - Add `ensure donk_truckgunplug` to your `server.cfg`

4. **Optional: Discord Role Whitelisting**
   - If you want to restrict access to specific Discord roles:
     - Install and configure `donk_api`
     - Configure your desired Discord role restrictions

## ⚙️ Configuration

Configuration options and setup instructions will depend on your specific server requirements. Make sure all dependencies are properly configured before using this script.

## 🎯 How It Works

- Players can use the third eye (ox_target) system on garbage trucks
- Interaction provides access to gun-related functionality
- Requires the specific garbage truck model from VoodooCustom
- Optional Discord role restrictions available with donk_api

## ⚠️ Important Notes

- **The garbage truck model from VoodooCustom is MANDATORY** - the script will not function without it
- Ensure all ox framework dependencies are up to date
- Test thoroughly before deploying to a live server

## 🔧 Support

For issues or questions:
- Check that all dependencies are properly installed
- Verify the VoodooCustom garbage truck model is correctly installed
- Ensure your ox framework components are up to date

---

**Developed by Donk**
