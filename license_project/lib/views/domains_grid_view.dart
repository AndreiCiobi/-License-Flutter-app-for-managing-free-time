import 'package:flutter/widgets.dart';
import 'package:license_project/helpers/components/cards/activity_card.dart';
import 'package:license_project/services/cloud/cloud_domain.dart';

typedef DomainCallBack = void Function(CloudDomain activity);

class DomainsGridView extends StatelessWidget {
  final Iterable<CloudDomain> domains;
  final DomainCallBack onTap;

  const DomainsGridView({
    super.key,
    required this.domains,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: domains.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final domain = domains.elementAt(index);
        return GestureDetector(
          onTap: () => onTap(domain),
          child: ActivityCard(
            name: domain.label,
            imageUrl: domain.imageUrl,
          ),
        );
      },
    );
  }
}
