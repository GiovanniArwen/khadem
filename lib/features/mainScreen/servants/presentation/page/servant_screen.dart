import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khadem/features/mainScreen/servants/presentation/bloc/servant_bloc.dart';
import 'package:khadem/features/mainScreen/servants/presentation/bloc/servant_event.dart';
import 'package:khadem/features/mainScreen/servants/presentation/bloc/servant_states.dart';
import 'package:khadem/features/mainScreen/servants/presentation/widgets/servant_card.dart';
import 'package:khadem/features/mainScreen/servants/presentation/widgets/servant_details_screen.dart';
import 'package:khadem/features/mainScreen/servants/presentation/widgets/servant_search_bar.dart';

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
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return const _FilterContent();
      },
    );
  }
}

class _FilterContent extends StatelessWidget {
  const _FilterContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'فلترة الخدام',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          const Text('نوع الخدمة'),

          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            children: [
              FilterChip(label: const Text('مرنم'), onSelected: (_) {}),
              FilterChip(label: const Text('واعظ'), onSelected: (_) {}),
              FilterChip(label: const Text('فريق تسبيح'), onSelected: (_) {}),
            ],
          ),

          const SizedBox(height: 20),

          const Text('المحافظة'),

          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            items: const [
              DropdownMenuItem(value: 'القاهرة', child: Text('القاهرة')),
              DropdownMenuItem(value: 'الجيزة', child: Text('الجيزة')),
              DropdownMenuItem(value: 'القليوبية', child: Text('القليوبية')),
            ],
            onChanged: (_) {},
            decoration: InputDecoration(
              hintText: 'اختار المحافظة',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('تطبيق الفلتر'),
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
