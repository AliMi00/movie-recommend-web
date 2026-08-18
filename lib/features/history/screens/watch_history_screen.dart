import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/movie_model.dart';
import '../providers/watch_history_providers.dart';
import '../../../shared/widgets/error_empty_state.dart';
import '../../../shared/providers/movie_providers.dart' show movieRepositoryProvider;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class WatchHistoryScreen extends ConsumerStatefulWidget { const WatchHistoryScreen({super.key}); @override ConsumerState<WatchHistoryScreen> createState()=> _WatchHistoryScreenState(); }

class _WatchHistoryScreenState extends ConsumerState<WatchHistoryScreen>{
	bool _grid = true;
	String _search = '';
	String? _genreFilter;
	final _scrollController = ScrollController();

	@override void initState(){ super.initState(); _scrollController.addListener(_onScroll); }
	void _onScroll(){ if(_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 200){ ref.read(watchHistoryProvider.notifier).loadMore(); } }
	@override void dispose(){ _scrollController.dispose(); super.dispose(); }

	@override Widget build(BuildContext context){
		final state = ref.watch(watchHistoryProvider);
		final movies = state.movies.where((m){ final matchQuery = _search.isEmpty || m.title.toLowerCase().contains(_search.toLowerCase()); final matchGenre = _genreFilter==null || m.genres.contains(_genreFilter); return matchQuery && matchGenre; }).toList();
		final allGenres = <String>{ for(final m in state.movies) ...m.genres }..removeWhere((g)=> g.trim().isEmpty);
		return Scaffold(
			appBar: AppBar(
        backgroundColor: Colors.transparent,
				title: const Text('Watch History'),
				actions: [
					IconButton(icon: Icon(_grid? Icons.view_list : Icons.grid_view), tooltip: 'Toggle layout', onPressed: ()=> setState(()=> _grid = !_grid)),
					IconButton(icon: const Icon(Icons.refresh), onPressed: ()=> ref.read(watchHistoryProvider.notifier).refresh()),
				],
				bottom: PreferredSize(preferredSize: const Size.fromHeight(60), child: Padding(
					padding: const EdgeInsets.fromLTRB(12,0,12,12),
					child: Row(children:[
						Expanded(child: TextField(decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Search history...', isDense: true, filled: true, fillColor: AppColors.surfaceContainerHigh, border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none)), onChanged: (v)=> setState(()=> _search = v))),
						const SizedBox(width:8),
						DropdownButton<String?>(
              value: _genreFilter, 
              hint: const Text('Genre'), 
              dropdownColor: AppColors.surfaceContainerHigh,
              underline: const SizedBox(),
              onChanged: (v)=> setState(()=> _genreFilter = v=='__ALL__'? null : v), 
              items: [ if(allGenres.isNotEmpty) const DropdownMenuItem(value: '__ALL__', child: Text('All')), ...allGenres.map((g)=> DropdownMenuItem(value: g, child: Text(g))) ]
            )
					]),
				)),
			),
			body: RefreshIndicator(
				onRefresh: ()=> ref.read(watchHistoryProvider.notifier).refresh(),
				child: Builder(builder: (context){
					if(state.isLoading && state.movies.isEmpty){ return const Center(child: CircularProgressIndicator()); }
					if(state.error!=null && state.movies.isEmpty){ return ErrorEmptyState.error(message: state.error!, onRetry: ()=> ref.read(watchHistoryProvider.notifier).loadInitial()); }
					if(movies.isEmpty){ return ListView(children:[ const SizedBox(height:40), ErrorEmptyState.empty(title: 'No watch history yet', message: 'Start swiping and your liked movies will appear here.', icon: Icons.history), const SizedBox(height:300) ]); }
					if(_grid){
						return GridView.builder(controller: _scrollController, padding: const EdgeInsets.all(12), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 2/3), itemCount: movies.length + (state.hasMore? 1:0), itemBuilder: (_, i){ if(i>= movies.length){ return const Center(child: CircularProgressIndicator()); } final m = movies[i]; return _HistoryGridTile(movie: m); });
					} else {
						return ListView.separated(controller: _scrollController, padding: const EdgeInsets.all(12), itemBuilder: (_, i){ if(i>= movies.length){ return const SizedBox(); } final m = movies[i]; return _HistoryListTile(movie: m); }, separatorBuilder: (_, __)=> const Divider(height:16, color: AppColors.outlineVariant), itemCount: movies.length);
					}
				}),
			),
			floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.onSecondary,
				tooltip: 'Add by ID',
				child: const Icon(Icons.add),
				onPressed: () async {
					final idController = TextEditingController();
					final formKey = GlobalKey<FormState>();
					final movie = await showDialog<Movie?>(context: context, builder: (ctx){
						return AlertDialog(
							title: const Text('Add Movie to History'),
							content: Form(
								key: formKey,
								child: SizedBox(
									width: 320,
									child: Column(
										mainAxisSize: MainAxisSize.min,
										children: [
											TextFormField(
												controller: idController,
												keyboardType: TextInputType.number,
												decoration: const InputDecoration(labelText: 'Movie ID'),
												validator: (v){
													if(v==null || v.trim().isEmpty) return 'Enter ID';
													if(int.tryParse(v.trim())==null) return 'Invalid number';
													return null;
												},
											),
											const SizedBox(height:12),
											const Text('Enter the ID of a known mock movie (e.g., 1001, 1002, 1003).')
										],
									),
								),
							),
							actions: [
								TextButton(onPressed: ()=> Navigator.pop(ctx), child: const Text('Cancel')),
								ElevatedButton(
									onPressed: () async {
										if(!(formKey.currentState?.validate()??false)) return;
										final id = int.parse(idController.text.trim());
										final repo = ref.read(movieRepositoryProvider);
										final m = await repo.getMovieDetails(id);
										if(m==null){
											if (!ctx.mounted) return;
											ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Movie not found')));
											return;
										}
										if (!ctx.mounted) return;
										Navigator.pop(ctx, m);
									},
									child: const Text('Add'),
								),
							],
						);
					});
					if(movie!=null){ await ref.read(watchHistoryProvider.notifier).addMovie(movie); }
				},
			),
		);
	}
}

class _HistoryGridTile extends StatelessWidget { const _HistoryGridTile({required this.movie}); final Movie movie; @override Widget build(BuildContext context){ return InkWell(onTap: (){ showDialog(context: context, builder: (_)=> AlertDialog(title: Text(movie.title), content: Text(movie.overview))); }, child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.surfaceContainerHigh), padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[ Expanded(child: Stack(children:[ Positioned.fill(child: movie.posterUrl != null ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(movie.fullPosterPath, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceContainerLow))) : Container(decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(8)), alignment: Alignment.center, child: Text(movie.title.isNotEmpty? movie.title[0] : '?', style: AppTextStyles.headlineLarge))), if(movie.isSuperLiked) Positioned(top:4,left:4, child: Container(padding: const EdgeInsets.symmetric(horizontal:6, vertical:2), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.tertiary,width:1)), child: const Icon(Icons.star_rounded, size:16, color: AppColors.tertiary))), ])), const SizedBox(height:6), Text(movie.title, maxLines:2, overflow: TextOverflow.ellipsis, style: AppTextStyles.labelSmall.copyWith(fontSize: 12)), const SizedBox(height:4), Text(movie.genres.take(2).join(', '), style: AppTextStyles.labelSmall.copyWith(fontSize: 10, color: AppColors.onSurfaceVariant)), ]))); }
}
class _HistoryListTile extends StatelessWidget {
	const _HistoryListTile({required this.movie});
	final Movie movie;
	@override
	Widget build(BuildContext context){
		return ListTile(
			contentPadding: const EdgeInsets.symmetric(horizontal:8, vertical:4),
			leading: movie.posterUrl != null ? ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(movie.fullPosterPath, width: 40, height: 60, fit: BoxFit.cover)) : CircleAvatar(
				backgroundColor: AppColors.surfaceContainerHigh,
				child: Text(movie.title.isNotEmpty? movie.title[0] : '?'),
			),
			title: Text(movie.title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
			subtitle: Text(movie.genres.join(', '), style: AppTextStyles.labelSmall.copyWith(fontSize: 11, color: AppColors.onSurfaceVariant)),
			trailing: movie.isSuperLiked ? const Icon(Icons.star_rounded, color: AppColors.tertiary) : (movie.likedAt!=null ? const Icon(Icons.favorite, color: AppColors.secondary) : null),
			onTap: (){
				showModalBottomSheet(context: context, backgroundColor: AppColors.surface, builder: (_)=> Padding(
					padding: const EdgeInsets.all(24),
					child: SingleChildScrollView(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children:[
								Text(movie.title, style: AppTextStyles.headlineLarge),
								const SizedBox(height:8),
								Text(movie.overview, style: AppTextStyles.bodyMedium),
								const SizedBox(height:16),
								Wrap(spacing:8, runSpacing: 8, children: movie.genres.map((g)=> Chip(label: Text(g), backgroundColor: AppColors.surfaceContainerHigh)).toList()),
							],
						),
					),
				));
			},
		);
	}
}
// Legacy _ErrorState removed in favor of ErrorEmptyState
