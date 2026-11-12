// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_intern_email_sends_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// This intern's own bulk-send history, most recent first — shown in the
/// Dashboard tab. `sendBrandProspectMassEmail` is the only writer.

@ProviderFor(myBrandEmailSends)
final myBrandEmailSendsProvider = MyBrandEmailSendsProvider._();

/// This intern's own bulk-send history, most recent first — shown in the
/// Dashboard tab. `sendBrandProspectMassEmail` is the only writer.

final class MyBrandEmailSendsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BrandEmailSend>>,
          List<BrandEmailSend>,
          Stream<List<BrandEmailSend>>
        >
    with
        $FutureModifier<List<BrandEmailSend>>,
        $StreamProvider<List<BrandEmailSend>> {
  /// This intern's own bulk-send history, most recent first — shown in the
  /// Dashboard tab. `sendBrandProspectMassEmail` is the only writer.
  MyBrandEmailSendsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myBrandEmailSendsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myBrandEmailSendsHash();

  @$internal
  @override
  $StreamProviderElement<List<BrandEmailSend>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BrandEmailSend>> create(Ref ref) {
    return myBrandEmailSends(ref);
  }
}

String _$myBrandEmailSendsHash() => r'f6a2f29087482ed55d88000db7a2d518419af9c7';
