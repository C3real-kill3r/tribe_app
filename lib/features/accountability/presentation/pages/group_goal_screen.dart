import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GroupGoalScreen extends StatelessWidget {
  const GroupGoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Trip to Costa Rica'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressCard(context),
                  const SizedBox(height: 32),
                  Text(
                    'Activity',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildActivityList(context),
                ],
              ),
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$1,950',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'of \$3,000 goal',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule,
                        size: 16, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      '15 days left',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.65,
              minHeight: 8,
              backgroundColor: Theme.of(context).dividerColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 108, // Width needed: last avatar at left:72 + width:36 = 108
                height: 36,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildContributorAvatar(0,
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuA5SM2W4AZClYHQ4fmsYWEC0prynYGkZtfuJ9xI0G1dFf2BoNkOFEU-QcHp8ojFUyDPdcAOLcUe614sHe00oLnoK9gV3AhYDUReMmJZmTt0XH9G65SLWs66SPg57iigfr7rypq7UDck0xMA1ivb0fMKtiyHbiTeXUI9z6sHHG40nxuFp1uDaXe1fpdzusdxrt7OQ_sc3Z8GhJTnwZw_ZMwCTIpF0XSJbDgfhbnBGemLFrlZVHinqazkpGl9LH2D-su0fGTnQtess3I'),
                    _buildContributorAvatar(24,
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDMNmBS9SRYkSnO12HlK_VSW0a9lsde7L3QEDQmHAuLygDWKfRIXhKJ8r0AsWyR_oTZgcnvOf9fVgiKKJ_ibltJeoFZD-QtyHbbZZfj3EPpqcmwXQqnHTrxXtts9qYH6zYkYIHxq7mHpHX9_BSK4KfO9DiJNIy7NBkCWOwSeAUwPTkBv28no_v_NnQoAX2BYsaQ61mwhlRZYb5H9EBVQMyDCqjevwuqm8_7u0VnRSrYcIe7n947RJH1DrC5qulEZcrhPjgKPm_LytM'),
                    _buildContributorAvatar(48,
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuD4hMGiCBfOpu2R4iT4N2oax7--giEIkXPa2Ymt10ZZamivrxIHlQpG6m97upPj7G1hMv1wWqpfQSfSL3nWkm47h4KTR3jqam-G8AXVARljUBgrCvYpeHfLxCjZA49vT-v89Amz6vUxiJtVF82bja87sqgPzetWpcY-q9wb86Y4NccQTZN1NaamfkO_Tmr_aG8M8-ZfGt8SjFehhV7kkTtkIDP0_SGe511EJuYjiqLiHvh_gHwwJYCwpIQFWSat3s9AVP_PSWuvceY'),
                    _buildContributorAvatar(72,
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuCQaEGfhq70y_s2vl_5kei92vYOUXVX1j8--wNSGToSccPMluY4qzUKBxPhD8C47i0fxYLoLsEjn4Qh_uJbWjkrRW2AlkD-tfYNPdCsnJjJUZ1714uHGWHRJSTfFqiRIHk-S0e-mRHYU1QXOZ7sTnkaeJT-uE7lqUzDYprXQJn7_OpFHfRJXd9KoM2Ic6hXDx2fAKc-AWGibxV7hDUies8u07kZd9hnGpMKARdT3NYn61KrAynGh_HQE_k81LfYEu43SBI2U9zQyXM'),
                  ],
                ),
              ),
              Text(
                '65% Funded',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContributorAvatar(double left, String imageUrl) {
    return Positioned(
      left: left,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildActivityList(BuildContext context) {
    return Column(
      children: [
        _buildActivityItem(
          context,
          'Clarie Gor',
          'Today, 10:45 AM',
          '+\$150.00',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAXIgJFP1_4tPGZl--ySZm5ouUI6hRrudnC7_o2bHXCcbcMrciRmwFs5h_aIpnJT_tpsTUl6RZaV8377GRRc7od4I8HVyoO2-FWG_mrwlcXSuyVvVlg66HvI7JVuTah5TrWSN9vKcicHq2XrRW0GSG9yI0nZ46gOgluWbJCVe1KzaMe5mrlrPr_vsii_nG-8PMcmKGwfnxKCS7ygGtSI6Xk9NaVjRnd8PuTGABkSRNDktKhhypWaM_AjluWDsjyWa92-ofelQEUvz8',
        ),
        _buildActivityItem(
          context,
          'Alvin Amwata',
          'Yesterday, 8:12 PM',
          '+\$75.00',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBUqSvDAOii1mDTEunmZHOGCuHLLdrYEZxe-6fyUxPiqj0f76pEEOXXQlerd2xT6t3tQoEwShsDDebkLQhk3yDiz7aBRwlL7rjAlQV7eBr7httg86IXOHSUGe8cL089oUtQzotvbgkPAZI9XfjQHPdcue--IhbD6LGsn4Lo5R3drlcd6oVkyRb1ESDzLPi49YhMPCuDEEoUQtET2TpFVbnl_pZpR2NEhG-FMd4H539wXEyPlTv2bRDZXWZwVxwAU1jHjuNFt82sQkI',
        ),
        _buildActivityItem(
          context,
          'Frank Amwata',
          '3 days ago',
          '+\$200.00',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB3xgCmpxXaYVEcgDTuX0JxG04a69Ucq2X1IMp6a4GDL7d7XveV8MOFrFhhDpD9U2IRosteUexmwihMq8fc7dJbaKN9IZ7t2lwnbyyMQA7zd4HcX7cx7rJRg5_bPhJTpBfsl_f-D9_g95PkfzeLz1jJw6NNsBMXLwtQ7cDJlINVDNuHcab7HHx4_763c8gNgwsRj05KZgweZ7sua5Rkw_D51mqCfExaKjtGws3sGEz-BAFFRbDZgLHkwd7xyOYMmHOGllIndk2QC2A',
        ),
      ],
    );
  }

  Widget _buildActivityItem(BuildContext context, String name, String time,
      String amount, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: () {},
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text('Contribute'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
