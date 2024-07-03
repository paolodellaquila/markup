//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

import '/app/models/customer_country.dart';
import '/resources/widgets/buttons.dart';
import '/resources/widgets/woosignal_ui.dart';

class CustomerAddressInput extends StatelessWidget {
  const CustomerAddressInput(
      {super.key,
      required this.txtControllerFirstName,
      required this.txtControllerLastName,
      required this.txtControllerAddressLine,
      required this.txtControllerCity,
      required this.txtControllerPostalCode,
      this.txtControllerEmailAddress,
      this.txtControllerPhoneNumber,
      required this.customerCountry,
      required this.onTapCountry});

  final TextEditingController? txtControllerFirstName,
      txtControllerLastName,
      txtControllerAddressLine,
      txtControllerCity,
      txtControllerPostalCode,
      txtControllerEmailAddress,
      txtControllerPhoneNumber;

  final CustomerCountry? customerCountry;
  final Function() onTapCountry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        Column(
          children: <Widget>[
            TextEditingRow(
              heading: trans("First Name"),
              controller: txtControllerFirstName,
              shouldAutoFocus: true,
            ),
            TextEditingRow(
              heading: trans("Last Name"),
              controller: txtControllerLastName,
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        ),
        Column(
          children: <Widget>[
            TextEditingRow(
              heading: trans("Address Line"),
              controller: txtControllerAddressLine,
            ),
            TextEditingRow(
              heading: trans("City"),
              controller: txtControllerCity,
            ),
          ],
        ),
        Column(
          children: <Widget>[
            TextEditingRow(
              heading: trans("Postal code"),
              controller: txtControllerPostalCode,
            ),
            if (txtControllerEmailAddress != null)
              TextEditingRow(heading: trans("Email address"), keyboardType: TextInputType.emailAddress, controller: txtControllerEmailAddress),
          ],
        ),
        if (txtControllerPhoneNumber != null)
          Column(
            children: <Widget>[
              TextEditingRow(
                heading: trans("Phone Number"),
                controller: txtControllerPhoneNumber,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            children: <Widget>[
              if (customerCountry?.hasState() ?? false)
                Column(
                  children: [
                    Container(
                      height: 23,
                      child: Text(
                        trans("State"),
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.left,
                      ),
                      width: double.infinity,
                    ),
                    Padding(
                      child: SecondaryButton(
                        title: (customerCountry!.state != null ? (customerCountry?.state?.name ?? "") : trans("Select state")),
                        action: onTapCountry,
                      ),
                      padding: EdgeInsets.all(8),
                    ),
                  ],
                ),
              Column(
                children: [
                  Container(
                    height: 23,
                    child: Text(
                      trans("Country"),
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.left,
                    ),
                    width: double.infinity,
                  ),
                  Padding(
                    child: SecondaryButton(
                      title: (customerCountry != null && (customerCountry?.name ?? "").isNotEmpty ? customerCountry!.name : trans("Select country")),
                      action: onTapCountry,
                    ),
                    padding: EdgeInsets.all(8),
                  ),
                ],
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
        ),
      ],
    );
  }
}
