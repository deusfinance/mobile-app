String showShortenedAddress(String walletAddress) =>
    '${walletAddress.substring(0, 4)}...${walletAddress.substring(walletAddress.length - 2)}';
