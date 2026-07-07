import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../models/species.dart';
import '../services/api_service.dart';

import 'species_detail_screen.dart';

class SpeciesListScreen extends StatefulWidget {
  const SpeciesListScreen({super.key});

  @override
  State<SpeciesListScreen> createState() => _SpeciesListScreenState();
}

class _SpeciesListScreenState extends State<SpeciesListScreen> {
  List<Species> _speciesList = [];
  List<Species> _filteredList = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSpecies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSpecies() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await ApiService.getAllSpecies();
      if (mounted) {
        setState(() {
          _speciesList = list;
          _filteredList = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _filterSpecies(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredList = _speciesList;
      });
      return;
    }

    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredList = _speciesList.where((s) {
        final matchesViet = s.tenViet.toLowerCase().contains(lowerQuery);
        final matchesScience = s.tenKhoaHoc.toLowerCase().contains(lowerQuery);
        final matchesClass = s.className.toLowerCase().contains(lowerQuery);
        return matchesViet || matchesScience || matchesClass;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF006079);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Danh sách loài bọ',
          style: GoogleFonts.sora(
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
        actions: [
          if (!_isLoading && _error == null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: primaryBlue),
              onPressed: _loadSpecies,
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? _buildLoading()
                : _error != null
                    ? _buildError()
                    : _buildGrid(primaryBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: TextField(
        controller: _searchController,
        onChanged: _filterSpecies,
        style: const TextStyle(color: Color(0xFF191C1D)),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm theo tên bọ...',
          hintStyle: const TextStyle(color: Color(0xFF6F797E)),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6F797E)),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Color(0xFF191C1D)),
                  onPressed: () {
                    _searchController.clear();
                    _filterSpecies('');
                  },
                ),

            ],
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFBEC8CD)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF006079), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE1E3E4),
      highlightColor: const Color(0xFFF3F4F5),
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBEC8CD)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 50,
                        height: 10,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFBA1A1A),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Lỗi tải danh sách loài',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: const Color(0xFF191C1D)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadSpecies,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006079),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(Color primaryBlue) {
    if (_filteredList.isEmpty) {
      return Center(
        child: Text(
          'Không tìm thấy loài bọ phù hợp.',
          style: GoogleFonts.inter(color: const Color(0xFF6F797E), fontSize: 15),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: _filteredList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final s = _filteredList[index];

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFBEC8CD).withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SpeciesDetailScreen(className: s.className),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      s.hinhAnhUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (ctx, err, stack) => Container(
                        color: const Color(0xFFEDEEEF),
                        child: const Icon(
                          Icons.bug_report_rounded,
                          color: Color(0xFF006079),
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
                // Text Area
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.tenViet.isNotEmpty ? s.tenViet : s.className,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.sora(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF191C1D),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.tenKhoaHoc.isNotEmpty ? s.tenKhoaHoc : s.className,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF006079),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}