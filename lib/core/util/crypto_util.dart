String showShortenedAddress(String walletAddress) =>
    '${walletAddress.substring(0, 8)}...${walletAddress.substring(walletAddress.length - 4)}';
