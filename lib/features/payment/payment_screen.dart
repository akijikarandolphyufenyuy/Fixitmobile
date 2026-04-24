import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../../data/models/app_transaction.dart';
import '../../data/repositories/transaction_repository.dart';

const _kOrange = Color(0xFFF77705);
const _kOrangeDark = Color(0xFFE86E00);
const _kOrangeLight = Color(0xFFFF9A3C);
const _kBrown = Color(0xFF1C110C);
const _kBrownMid = Color(0xFF9E7047);
const _kBrownLight = Color(0xFFE8D8CE);
const _kCream = Color(0xFFFCF9F7);

/// [purpose]   — 'post_job' or 'view_job'
/// [amount]    — amount in FCFA
/// [onSuccess] — called after payment success
class PaymentScreen extends StatefulWidget {
  final String purpose;
  final int amount;
  final String? jobTitle;
  final VoidCallback onSuccess;

  const PaymentScreen({
    super.key,
    required this.purpose,
    required this.amount,
    required this.onSuccess,
    this.jobTitle,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with TickerProviderStateMixin {
  final _phoneCtrl = TextEditingController();
  String _selectedMethod = 'orange';
  bool _processing = false;
  bool _success = false;
  bool _failed = false;
  String _failMessage = '';

  late AnimationController _headerCtrl;
  late Animation<Offset> _headerSlide;
  late Animation<double> _headerFade;

  late AnimationController _successCtrl;
  late Animation<double> _successScale;
  late Animation<double> _successFade;
  late Animation<double> _checkDraw;

  double get _headerHeight {
    final top =
        WidgetsBinding.instance.platformDispatcher.views.first.padding.top /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    return top + 72;
  }

  @override
  void initState() {
    super.initState();

    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));
    _headerCtrl.forward();

    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _successScale = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut));
    _successFade = CurvedAnimation(parent: _successCtrl, curve: Curves.easeIn);
    _checkDraw = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successCtrl,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _successCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  static const _kApplicationKey = 'd3cece37658c0d8dc1a517ecdfe826d768eb418d';
  static const _kAccessKey = '645f7eaf-c5b4-4bf5-97af-533b74a42d27';
  static const _kSecretKey = '6bfd0828-57de-439d-83d6-d1a806599afb';
  static const _kApiUrl =
      'https://mesomb.hachther.com/api/v1.1/payment/collect/';

  static String _nonce() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rng = Random.secure();
    return List.generate(40, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  static String _buildAuthorization({
    required DateTime date,
    required String nonce,
    required Map<String, dynamic> body,
  }) {
    final parsed = Uri.parse(_kApiUrl);
    final timestamp = (date.millisecondsSinceEpoch ~/ 1000).toString();
    final host = '${parsed.scheme}://${parsed.host}';

    final headers = <String, String>{
      'content-type': 'application/json; charset=utf-8',
      'host': host,
      'x-mesomb-date': timestamp,
      'x-mesomb-nonce': nonce,
    };
    final sortedKeys = headers.keys.toList()..sort();
    final canonicalHeaders = sortedKeys
        .map((k) => '$k:${headers[k]}')
        .join('\n');
    final signedHeaders = sortedKeys.join(';');
    final payloadHash = sha1.convert(utf8.encode(jsonEncode(body))).toString();
    final path = parsed.pathSegments.map(Uri.encodeComponent).join('/');
    final canonicalRequest =
        'POST\n/$path\n\n$canonicalHeaders\n$signedHeaders\n$payloadHash';

    final d = date;
    final scope =
        '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}/payment/mesomb_request';
    final stringToSign =
        'HMAC-SHA1\n$timestamp\n$scope\n${sha1.convert(utf8.encode(canonicalRequest)).toString()}';
    final signature = Hmac(
      sha1,
      utf8.encode(_kSecretKey),
    ).convert(utf8.encode(stringToSign)).toString();

    return 'HMAC-SHA1 Credential=$_kAccessKey/$scope, SignedHeaders=$signedHeaders, Signature=$signature';
  }

  Future<void> _pay() async {
    final phone = _phoneCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.length < 9) {
      _showSnack('Enter a valid phone number', isError: true);
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _processing = true;
      _failed = false;
      _failMessage = '';
    });

    try {
      final date = DateTime.now();
      final nonce = _nonce();
      final body = <String, dynamic>{
        'amount': widget.amount,
        'service': _selectedMethod == 'orange' ? 'ORANGE' : 'MTN',
        'payer': phone,
        'country': 'CM',
        'currency': 'XAF',
        'fees': true,
        'message': widget.purpose == 'post_job'
            ? 'Fixit - Job Posting Fee'
            : 'Fixit - Unlock Job Details',
        'source': 'MeSombDart/1.0.4',
      };

      final response = await http.post(
        Uri.parse(_kApiUrl),
        headers: {
          'Authorization': _buildAuthorization(
            date: date,
            nonce: nonce,
            body: body,
          ),
          'Content-Type': 'application/json; charset=utf-8',
          'X-MeSomb-Application': _kApplicationKey,
          'x-mesomb-date': (date.millisecondsSinceEpoch ~/ 1000).toString(),
          'x-mesomb-nonce': nonce,
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 400) {
        throw Exception(
          data['detail'] ?? data['message'] ?? 'HTTP ${response.statusCode}',
        );
      }
      if (!(data['success'] as bool? ?? false)) {
        throw Exception(data['message'] ?? 'Payment declined by the network.');
      }

      if (!mounted) return;
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (uid.isNotEmpty) {
        await TransactionRepository().saveTransaction(
          AppTransaction(
            userId: uid,
            purpose: widget.purpose,
            jobTitle: widget.jobTitle ?? '',
            amount: widget.amount,
            paymentMethod: _selectedMethod,
            phoneNumber: phone,
            paidAt: DateTime.now(),
            status: 'success',
            mesombRef:
                (data['transaction'] as Map?)?.cast<String, dynamic>()['pk']
                    as String?,
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _processing = false;
        _success = true;
      });
      _successCtrl.forward();
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 2200));
      if (!mounted) return;
      widget.onSuccess();
    } catch (e) {
      if (!mounted) return;
      HapticFeedback.vibrate();
      setState(() {
        _processing = false;
        _failed = true;
        _failMessage = e.toString().contains('SocketException')
            ? 'No internet connection. Check your network and try again.'
            : e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kCream,
      body: Stack(
        children: [
          CustomScrollView(
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
                  child: _PaymentHeader(
                    slideAnim: _headerSlide,
                    onBack: () => context.pop(),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAmountCard(),
                      const SizedBox(height: 28),
                      _sectionLabel('Payment Method'),
                      const SizedBox(height: 12),
                      _buildMethodSelector(),
                      const SizedBox(height: 24),
                      _sectionLabel('Mobile Number'),
                      const SizedBox(height: 12),
                      _buildPhoneField(),
                      const SizedBox(height: 12),
                      _buildNote(),
                      const SizedBox(height: 36),
                      _buildPayButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_success) _buildSuccessOverlay(),
          if (_failed) _buildFailureOverlay(),
        ],
      ),
    );
  }

  Widget _buildAmountCard() {
    final isPost = widget.purpose == 'post_job';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kOrangeDark, _kOrange, _kOrangeLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _kOrange.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Opacity(
              opacity: 0.12,
              child: Icon(
                isPost ? Icons.work_outline_rounded : Icons.lock_open_rounded,
                size: 100,
                color: Colors.white,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isPost ? 'Job Posting Fee' : 'Unlock Job Details',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${widget.amount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8, left: 6),
                    child: Text(
                      'FCFA',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                isPost
                    ? 'Pay once to publish your job listing'
                    : 'Unlock location & contact info${widget.jobTitle != null ? '\nfor "${widget.jobTitle}"' : ''}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodSelector() {
    return Row(
      children: [
        Expanded(
          child: _MethodTile(
            label: 'Orange Money',
            color: const Color(0xFFFF6600),
            isOrange: true,
            selected: _selectedMethod == 'orange',
            onTap: () => setState(() => _selectedMethod = 'orange'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MethodTile(
            label: 'MTN MoMo',
            color: const Color(0xFFFFBB00),
            isOrange: false,
            selected: _selectedMethod == 'mtn',
            onTap: () => setState(() => _selectedMethod = 'mtn'),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    final isOrange = _selectedMethod == 'orange';
    final accent = isOrange ? const Color(0xFFFF6600) : const Color(0xFFFFBB00);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBrownLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
            ),
            child: Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CustomPaint(
                  painter: isOrange
                      ? _OrangeMoneyLogoPainter()
                      : _MtnLogoPainter(),
                ),
              ),
            ),
          ),
          Container(width: 1, height: 36, color: _kBrownLight),
          Expanded(
            child: TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumber],
              style: const TextStyle(
                color: _kBrown,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                hintText: 'e.g. 6 XX XX XX XX',
                hintStyle: TextStyle(
                  color: _kBrownMid,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kOrange.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kOrange.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: _kOrange, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'You will receive a prompt on your phone to confirm the payment of ${widget.amount} FCFA.',
              style: const TextStyle(
                color: _kBrownMid,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _processing
              ? const LinearGradient(colors: [_kBrownLight, _kBrownLight])
              : const LinearGradient(
                  colors: [_kOrangeDark, _kOrange, _kOrangeLight],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: _processing
              ? []
              : [
                  BoxShadow(
                    color: _kOrange.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: _processing ? null : _pay,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _processing
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Processing...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_open_rounded, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Pay ${widget.amount} FCFA',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return FadeTransition(
      opacity: _successFade,
      child: Container(
        color: Colors.black.withValues(alpha: 0.55),
        child: Center(
          child: ScaleTransition(
            scale: _successScale,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _checkDraw,
                    builder: (_, __) => CustomPaint(
                      size: const Size(80, 80),
                      painter: _SuccessCirclePainter(_checkDraw.value),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Payment Successful!',
                    style: TextStyle(
                      color: _kBrown,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.purpose == 'post_job'
                        ? '🎉 Your job is being published!'
                        : '🔓 Job details unlocked!',
                    style: const TextStyle(
                      color: _kBrownMid,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFailureOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.55),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red.shade400,
                  size: 38,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Payment Failed',
                style: TextStyle(
                  color: _kBrown,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _failMessage,
                style: const TextStyle(
                  color: _kBrownMid,
                  fontSize: 13,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _failed = false);
                        context.pop();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _kBrownLight),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: _kBrownMid,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_kOrangeDark, _kOrange],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ElevatedButton(
                        onPressed: () => setState(() => _failed = false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Try Again',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
    label.toUpperCase(),
    style: const TextStyle(
      color: _kBrownMid,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
    ),
  );
}

// ─── Method Tile ──────────────────────────────────────────────────────────────
class _MethodTile extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final bool isOrange;

  const _MethodTile({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
    required this.isOrange,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.10) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : _kBrownLight,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CustomPaint(
                painter: isOrange
                    ? _OrangeMoneyLogoPainter()
                    : _MtnLogoPainter(),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? color : _kBrownMid,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 6),
              Icon(Icons.check_circle_rounded, color: color, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Payment Header ───────────────────────────────────────────────────────────
class _PaymentHeader extends StatelessWidget {
  final Animation<Offset> slideAnim;
  final VoidCallback onBack;

  const _PaymentHeader({required this.slideAnim, required this.onBack});

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
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
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
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Secure',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Payment',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
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

// ─── Success Circle Painter ───────────────────────────────────────────────────
class _SuccessCirclePainter extends CustomPainter {
  final double progress;
  _SuccessCirclePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = const Color(0xFF4CAF50).withValues(alpha: 0.12),
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      -1.5708,
      6.2832 * progress,
      false,
      Paint()
        ..color = const Color(0xFF4CAF50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    if (progress > 0.5) {
      final t = ((progress - 0.5) / 0.5).clamp(0.0, 1.0);
      final p1 = Offset(size.width * 0.28, size.height * 0.52);
      final p2 = Offset(size.width * 0.44, size.height * 0.66);
      final p3 = Offset(size.width * 0.72, size.height * 0.36);

      final path = Path();
      if (t < 0.5) {
        final tt = t / 0.5;
        path.moveTo(p1.dx, p1.dy);
        path.lineTo(p1.dx + (p2.dx - p1.dx) * tt, p1.dy + (p2.dy - p1.dy) * tt);
      } else {
        final tt = (t - 0.5) / 0.5;
        path.moveTo(p1.dx, p1.dy);
        path.lineTo(p2.dx, p2.dy);
        path.lineTo(p2.dx + (p3.dx - p2.dx) * tt, p2.dy + (p3.dy - p2.dy) * tt);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF4CAF50)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(_SuccessCirclePainter old) => old.progress != progress;
}

// ─── Orange Money Logo Painter ────────────────────────────────────────────────
class _OrangeMoneyLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()..color = const Color(0xFF000000),
    );

    canvas.drawCircle(
      Offset(cx, cy),
      r - 1,
      Paint()
        ..color = const Color(0xFFFF6600)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.18,
    );

    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.62,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.06,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: 'om',
        style: TextStyle(
          color: Colors.white,
          fontSize: r * 0.72,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_OrangeMoneyLogoPainter old) => false;
}

// ─── MTN Logo Painter ─────────────────────────────────────────────────────────
class _MtnLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(w * 0.18),
    );
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFFFFBB00));

    final tp = TextPainter(
      text: TextSpan(
        text: 'MTN',
        style: TextStyle(
          color: const Color(0xFF003087),
          fontSize: h * 0.38,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(w / 2 - tp.width / 2, h * 0.18));

    final barY = h * 0.64;
    final barH = h * 0.10;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.08, barY, w * 0.84, barH),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFCC0000),
    );

    final sub = TextPainter(
      text: TextSpan(
        text: 'MoMo',
        style: TextStyle(
          color: const Color(0xFF003087),
          fontSize: h * 0.22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    sub.paint(canvas, Offset(w / 2 - sub.width / 2, h * 0.76));
  }

  @override
  bool shouldRepaint(_MtnLogoPainter old) => false;
}
