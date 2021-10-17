import '../../core/widgets/default_screen/default_screen.dart';
import '../../infrastructure/wallet_provider/wallet_handler.dart';
import '../../infrastructure/wallet_provider/wallet_provider.dart';
import '../../locator.dart';
import '../../routes/navigation_service.dart';
import '../wallet_intro_screen/intro_page.dart';
import '../../service/address_service.dart';
import '../../service/config_service.dart';
import '../../statics/my_colors.dart';
import '../../statics/styles.dart';
import 'package:flutter/material.dart';
import '../../core/util/clipboard.dart';
import 'package:web3dart/credentials.dart';

enum copyMenu { walletAddress, seedPhrase, privateKey }

class WalletSettingsScreen extends StatefulWidget {
  static const url = '/wallet-settings';

  @override
  _WalletSettingsScreenState createState() => _WalletSettingsScreenState();
}

class _WalletSettingsScreenState extends State<WalletSettingsScreen> {
  bool _showLogOutDialogue = false;
  final int _selectedWalletIndex = 0;

  @override
  Widget build(BuildContext context) {
    final WalletHandler walletStore = useWallet(context);
    return DefaultScreen(
      child: _showLogOutDialogue
          ? _buildLogOutWalletBody(walletStore)
          : _buildListBody(),
    );
  }

  Container _buildLogOutWalletBody(WalletHandler walletStore) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 45),
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 40),
      decoration: BoxDecoration(
          color: MyColors.ToastRed.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: MyColors.ToastRed)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 100,
          ),
          Text(
            'WARNING',
            style:
                MyStyles.whiteBigTextStyle.copyWith(color: MyColors.ToastRed),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "Without your seed phrase or private key you cannot restore your wallet balance!",
            style: MyStyles.whiteMediumTextStyle
                .copyWith(color: MyColors.ToastRed),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                  child: InkWell(
                onTap: () {
                  setState(() {
                    _showLogOutDialogue = false;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: MyColors.ToastGreen),
                      color: MyColors.Button_BG_Black),
                  child: Center(
                    child: Text(
                      'CANCEL',
                      style: MyStyles.whiteSmallTextStyle
                          .copyWith(color: MyColors.ToastGreen),
                    ),
                  ),
                ),
              )),
              const SizedBox(width: 20),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    await walletStore.resetWallet();
                    _showLogOutDialogue = false;
                    await locator<NavigationService>()
                        .navigateTo(IntroPage.url, context, replaceAll: true);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: MyColors.ToastRed),
                        color: MyColors.Button_BG_Black),
                    child: Center(
                      child: Text(
                        'RESET WALLET',
                        style: MyStyles.whiteSmallTextStyle
                            .copyWith(color: MyColors.ToastRed),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30)
        ],
      ),
    );
  }

  Widget _buildListBody() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              'Your Wallet',
              style: MyStyles.whiteBigTextStyle,
            ),
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () =>
                locator<NavigationService>().navigateTo(IntroPage.url, context),
            child: Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 15),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: MyColors.Button_BG_Black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: MyColors.Selected_Grey)),
              child: Row(
                children: [
                  // PlatformSvg.asset('icons/addWalletIcon.svg'),
                  const SizedBox(
                    width: 12,
                  ),
                  const Text('Multiple Wallets coming soon!'),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          FutureBuilder(
              future: locator<AddressService>().getPublicAddress(),
              builder: (_, snapshot) {
                if (snapshot.hasData) {
                  return ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (ctx, ind) => _buildWalletListTile(
                          (snapshot.data as EthereumAddress).hex,
                          _selectedWalletIndex == ind),
                      separatorBuilder: (_, __) => const SizedBox(
                            height: 10,
                          ),
                      itemCount: 1);
                }
                return const Center(child: CircularProgressIndicator());
              }),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildWalletListTile(String walletAddress, bool selected) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.only(left: 16, right: 10, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: selected ? MyColors.Selected_Grey : MyColors.Button_BG_Black,
        border: Border.all(color: MyColors.Selected_Grey),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          if (selected) const Icon(Icons.check),
          if (selected)
            const SizedBox(
              width: 10,
            ),
          Text(
            '${walletAddress.substring(0, 8)}...${walletAddress.substring(walletAddress.length - 4)}',
            style: MyStyles.whiteSmallTextStyle,
          ),
          const Spacer(),
          InkWell(
            onTap: () {
              setState(() {
                _showLogOutDialogue = true;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: MyColors.ToastRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: MyColors.ToastRed)),
              child: Text(
                'LOG OUT',
                style: MyStyles.whiteMediumTextStyle
                    .copyWith(fontSize: 12.5, color: MyColors.ToastRed),
              ),
            ),
          ),
          PopupMenuButton<copyMenu>(
              padding:
                  const EdgeInsets.only(top: 5, bottom: 5, right: 0, left: 5),
              color: MyColors.Button_BG_Black,
              icon: const Icon(Icons.more_vert_rounded),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              onSelected: (copyMenu result) async {
                String? content;
                if (result == copyMenu.walletAddress) {
                  content = walletAddress;
                } else if (result == copyMenu.seedPhrase) {
                  content = locator<AddressService>().getMnemonic()!;
                } else if (result == copyMenu.privateKey) {
                  content = locator<ConfigurationService>().getPrivateKey()!;
                }
                await copyToClipBoard(content!);
              },
              itemBuilder: (context) {
                final List<PopupMenuEntry<copyMenu>> list = [];
                list.add(
                  PopupMenuItem<copyMenu>(
                      value: copyMenu.walletAddress,
                      child: Text(
                        'Copy wallet address',
                        style: MyStyles.whiteMediumTextStyle
                            .copyWith(fontSize: 15),
                      )),
                );
                list.add(const PopupMenuDivider(
                  height: 10,
                ));
                list.add(
                  PopupMenuItem<copyMenu>(
                      value: copyMenu.seedPhrase,
                      child: Text(
                        'Copy seed phrase',
                        style: MyStyles.whiteMediumTextStyle
                            .copyWith(fontSize: 15),
                      )),
                );
                list.add(const PopupMenuDivider(
                  height: 10,
                ));
                list.add(
                  PopupMenuItem<copyMenu>(
                      value: copyMenu.privateKey,
                      child: Text(
                        'Copy Private key',
                        style: MyStyles.whiteMediumTextStyle
                            .copyWith(fontSize: 15),
                      )),
                );
                return list;
              })
        ],
      ),
    );
  }
}
