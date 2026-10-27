import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khadem/features/main_screen/servants/presentation/bloc/servant_bloc.dart';
import 'package:khadem/features/main_screen/servants/presentation/bloc/servant_event.dart';
import 'package:khadem/features/main_screen/servants/presentation/bloc/servant_states.dart';
import 'package:khadem/features/main_screen/servants/presentation/widgets/servant_card.dart';
import 'package:khadem/features/main_screen/servants/presentation/pages/servant_details_screen.dart';
import 'package:khadem/features/main_screen/servants/presentation/widgets/servant_search_bar.dart';

class ServantsScreen extends StatelessWidget {
  const ServantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServantBloc()..add(LoadServantsEvent()),
      child: const _ServantsView(),
    );
  }
}

class _ServantsView extends StatelessWidget {
  const _ServantsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الخدام',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ServantSearchBar(
              onChanged: (value) {
                context.read<ServantBloc>().add(SearchServantsEvent(value));
              },
              onFilterPressed: () {
                _showFilterSheet(context);
              },
            ),

            const SizedBox(height: 20),

            Expanded(
              child: BlocBuilder<ServantBloc, ServantState>(
                builder: (context, state) {
                  if (state is ServantLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ServantErrorState) {
                    return Center(child: Text(state.message));
                  }

                  if (state is ServantLoadedState) {
                    if (state.servants.isEmpty) {
                      return const Center(
                        child: Text('لا يوجد خدام مطابقين للبحث'),
                      );
                    }

                    return ListView.builder(
                      itemCount: state.servants.length,
                      itemBuilder: (context, index) {
                        final servant = state.servants[index];

                        return ServantCard(
                          servant: servant,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ServantDetailsScreen(servant: servant),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final servantBloc = context.read<ServantBloc>();

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: servantBloc,
          child: const _FilterContent(),
        );
      },
    );
  }
}

class _FilterContent extends StatefulWidget {
  const _FilterContent();

  @override
  State<_FilterContent> createState() => _FilterContentState();
}

class _FilterContentState extends State<_FilterContent> {
  Set<String> selectedSpecializations = {};
  String? selectedGovernorate;

  final List<String> specializations = [
    'مرنم',
    'واعظ',
    'فريق تسبيح',
    'فريق دراما',
    'عازف',
  ];

  final List<String> governorates = ['القاهرة', 'الجيزة', 'القليوبية'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'فلترة الخدام',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              const Text(
                'نوع الخدمة',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: specializations.map((specialization) {
                  final isSelected = selectedSpecializations.contains(
                    specialization,
                  );
                  return FilterChip(
                    label: Text(specialization),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedSpecializations.add(specialization);
                        } else {
                          selectedSpecializations.remove(specialization);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              const Text(
                'المحافظة',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: selectedGovernorate,
                items: governorates.map((governorate) {
                  return DropdownMenuItem(
                    value: governorate,
                    child: Text(governorate),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedGovernorate = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'اختار المحافظة',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          selectedSpecializations.clear();
                          selectedGovernorate = null;
                        });
                      },
                      child: const Text('إعادة ضبط'),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<ServantBloc>().add(
                          FilterServantsEvent(
                            specializations: selectedSpecializations.toList(),
                            governorate: selectedGovernorate,
                          ),
                        );

                        Navigator.pop(context);
                      },
                      child: const Text('تطبيق الفلتر'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
