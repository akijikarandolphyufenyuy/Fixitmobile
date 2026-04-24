import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../data/models/app_transaction.dart';
import '../../data/repositories/transaction_repository.dart';
import '../widgets/app_nav_bar.dart';

const _kOrange      = Color(0xFFF77705);
const _kOrangeDark  = Color(0xFFE86E00);
const _kOrangeLight = Color(0xFFFF9A3C);
const _kBrown       = Color(0xFF1C110C);
const _kBrownMid    = Color(0xFF9E7047);
const _kBrownLight  = Color(0xFFE8D8CE);
const _kCream       = Color(0xFFFCF9F7);

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _headerCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  double get _headerHeight {
    final top = WidgetsBinding.instance.platformDispatcher.views.first.padding.top /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    return top + 72;
  }

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _headerFade  = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));
    _headerCtrl.forward();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: _kCream,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: _headerHeight,
            collapsedHeight: _headerHeight,
            toolbarHeight: _headerHeight,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FadeTransition(
              opacity: _headerFade,
              child: _TxHeader(
                slideAnim: _headerSlide,
                onBack: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/dashboard/settings');
                  }
                },
              ),
            ),
          ),
          if (uid == null)
            const SliverFillRemaining(
              child: Center(child: Text('Not logged in', style: TextStyle(color: _kBrownMid))),
            )
          else
            StreamBuilder<List<AppTransaction>>(
              stream: TransactionRepository().streamUserTransactions(uid),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: _kOrange)),
                  );
                }
                final txs = snap.data ?? [];
                if (txs.isEmpty) {
                  return SliverFillRemaining(child: _buildEmpty());
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _TxCard(tx: txs[i], index: i),
                      childCount: txs.length,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      bottomNavigationBar: const AppNavBar(selectedIndex: 4),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: _kOrange.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_rounded, color: _kOrange, size: 38),
          ),
          const SizedBox(height: 20),
          const Text('No Transactions Yet',
              style: TextStyle(color: _kBrown, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Your payment receipts will appear here',
              style: TextStyle(color: _kBrownMid, fontSize: 14)),
        ],
      ),
    );
  }
}

// ─── Transaction Card ─────────────────────────────────────────────────────────
class _TxCard extends StatelessWidget {
  final AppTransaction tx;
  final int index;

  const _TxCard({required this.tx, required this.index});

  @override
  Widget build(BuildContext context) {
    final isPost = tx.purpose == 'post_job';
    final methodColor = tx.paymentMethod == 'orange'
        ? const Color(0xFFFF6600)
        : const Color(0xFFFFCC00);
    final methodLabel = tx.paymentMethod == 'orange' ? 'Orange Money' : 'MTN MoMo';
    final methodEmoji = tx.paymentMethod == 'orange' ? '🟠' : '🟡';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 60).clamp(0, 400)),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 20 * (1 - v)), child: child),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: [
              // Top row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isPost
                              ? [_kOrangeDark, _kOrangeLight]
                              : [const Color(0xFF11998E), const Color(0xFF38EF7D)],
                        ),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        isPost ? Icons.work_outline_rounded : Icons.lock_open_rounded,
                        color: Colors.white, size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPost ? 'Job Posting Fee' : 'Unlock Job Details',
                            style: const TextStyle(color: _kBrown, fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            tx.jobTitle,
                            style: const TextStyle(color: _kBrownMid, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${tx.amount} FCFA',
                          style: const TextStyle(color: _kBrown, fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Paid', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1, color: _kBrownLight.withValues(alpha: 0.5)),
              ),
              // Bottom row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: Row(
                  children: [
                    Text(methodEmoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      methodLabel,
                      style: TextStyle(color: methodColor, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Text('·', style: TextStyle(color: _kBrownMid.withValues(alpha: 0.5))),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(tx.paidAt),
                      style: const TextStyle(color: _kBrownMid, fontSize: 12),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        await Future.delayed(Duration.zero);
                        if (!context.mounted) return;
                        _showReceiptSheet(context, tx);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _kOrange.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _kOrange.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_rounded, color: _kOrange, size: 14),
                            SizedBox(width: 5),
                            Text('Receipt', style: TextStyle(color: _kOrange, fontSize: 12, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final p = dt.hour < 12 ? 'AM' : 'PM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  $h:$m $p';
  }

  void _showReceiptSheet(BuildContext context, AppTransaction tx) {
    Future.delayed(Duration.zero, () {
      if (!context.mounted) return;
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => _ReceiptSheet(tx: tx),
      );
    });
  }
}

// ─── Receipt Sheet ────────────────────────────────────────────────────────────
class _ReceiptSheet extends StatelessWidget {
  final AppTransaction tx;
  const _ReceiptSheet({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isPost = tx.purpose == 'post_job';
    final methodLabel = tx.paymentMethod == 'orange' ? 'Orange Money' : 'MTN MoMo';
    final methodEmoji = tx.paymentMethod == 'orange' ? '🟠' : '🟡';
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dt = tx.paidAt;
    final dateStr = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final p = dt.hour < 12 ? 'AM' : 'PM';
    final timeStr = '$h:$m $p';

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: _kBrownLight, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          // Receipt header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 36),
                ),
                const SizedBox(height: 12),
                const Text('Payment Receipt',
                    style: TextStyle(color: _kBrown, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Transaction ID: ${tx.id?.substring(0, 12) ?? '—'}...',
                    style: const TextStyle(color: _kBrownMid, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Dashed divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _DashedDivider(),
          ),
          const SizedBox(height: 16),
          // Receipt rows
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _receiptRow('Service', isPost ? 'Job Posting Fee' : 'Unlock Job Details'),
                _receiptRow('Job', tx.jobTitle),
                _receiptRow('Amount', '${tx.amount} FCFA'),
                _receiptRow('Method', '$methodEmoji  $methodLabel'),
                _receiptRow('Phone', tx.phoneNumber),
                _receiptRow('Date', dateStr),
                _receiptRow('Time', timeStr),
                if (tx.mesombRef != null)
                  _receiptRow('Ref', tx.mesombRef!),
                _receiptRow('Status', '✅ Success'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _DashedDivider(),
          ),
          const SizedBox(height: 20),
          // Amount total
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Paid',
                    style: TextStyle(color: _kBrown, fontSize: 16, fontWeight: FontWeight.w700)),
                Text('${tx.amount} FCFA',
                    style: const TextStyle(color: _kOrange, fontSize: 22, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Download button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_kOrangeDark, _kOrange, _kOrangeLight],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: _kOrange.withValues(alpha: 0.4), blurRadius: 14, offset: const Offset(0, 5))],
                ),
                child: ElevatedButton.icon(
                  onPressed: () => _downloadPdf(context),
                  icon: const Icon(Icons.download_rounded, size: 20),
                  label: const Text('Download Receipt', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: _kBrownMid, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(color: _kBrown, fontSize: 13, fontWeight: FontWeight.w600),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPdf(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final isPost = tx.purpose == 'post_job';
    final methodLabel = tx.paymentMethod == 'orange' ? 'Orange Money' : 'MTN MoMo';
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dt = tx.paidAt;
    final dateStr = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final p = dt.hour < 12 ? 'AM' : 'PM';

    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context ctx) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(24),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('F77705'),
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('FIXIT', style: pw.TextStyle(color: PdfColors.white, fontSize: 28, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('Payment Receipt', style: pw.TextStyle(color: PdfColors.white, fontSize: 14)),
                ],
              ),
            ),
            pw.SizedBox(height: 24),
            // Transaction ID
            pw.Text('Transaction ID: ${tx.id ?? '—'}',
                style: pw.TextStyle(color: PdfColor.fromHex('9E7047'), fontSize: 11)),
            pw.SizedBox(height: 20),
            pw.Divider(color: PdfColor.fromHex('E8D8CE')),
            pw.SizedBox(height: 16),
            // Details
            _pdfRow('Service', isPost ? 'Job Posting Fee' : 'Unlock Job Details'),
            _pdfRow('Job Title', tx.jobTitle),
            _pdfRow('Amount', '${tx.amount} FCFA'),
            _pdfRow('Payment Method', methodLabel),
            _pdfRow('Phone Number', tx.phoneNumber),
            _pdfRow('Date', dateStr),
            _pdfRow('Time', '$h:$m $p'),
            if (tx.mesombRef != null) _pdfRow('MeSomb Ref', tx.mesombRef!),
            _pdfRow('Status', 'SUCCESS'),
            pw.SizedBox(height: 16),
            pw.Divider(color: PdfColor.fromHex('E8D8CE')),
            pw.SizedBox(height: 16),
            // Total
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('TOTAL PAID',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('1C110C'))),
                pw.Text('${tx.amount} FCFA',
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('F77705'))),
              ],
            ),
            pw.Spacer(),
            pw.Center(
              child: pw.Text('Thank you for using Fixit!',
                  style: pw.TextStyle(color: PdfColor.fromHex('9E7047'), fontSize: 12)),
            ),
          ],
        );
      },
    ));

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'fixit_receipt_${tx.id?.substring(0, 8) ?? 'receipt'}.pdf',
    );
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 130,
            child: pw.Text(label,
                style: pw.TextStyle(color: PdfColor.fromHex('9E7047'), fontSize: 12)),
          ),
          pw.Expanded(
            child: pw.Text(value,
                style: pw.TextStyle(color: PdfColor.fromHex('1C110C'), fontSize: 12, fontWeight: pw.FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─── Dashed Divider ───────────────────────────────────────────────────────────
class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      const dashW = 6.0;
      const gap = 4.0;
      final count = (constraints.maxWidth / (dashW + gap)).floor();
      return Row(
        children: List.generate(count, (_) => Padding(
          padding: const EdgeInsets.only(right: gap),
          child: Container(width: dashW, height: 1.5, color: _kBrownLight),
        )),
      );
    });
  }
}

// ─── Transactions Header ──────────────────────────────────────────────────────
class _TxHeader extends StatelessWidget {
  final Animation<Offset> slideAnim;
  final VoidCallback onBack;

  const _TxHeader({required this.slideAnim, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kOrangeDark, _kOrange, _kOrangeLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(top: topPadding),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
              child: Opacity(
                opacity: 0.15,
                child: Image.asset('assets/images/nn.png', fit: BoxFit.cover),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: SlideTransition(
              position: slideAnim,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onBack,
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Payments', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w400)),
                        SizedBox(height: 2),
                        Text('Transaction History', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3, height: 1.1)),
                      ],
                    ),
                  ),
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
