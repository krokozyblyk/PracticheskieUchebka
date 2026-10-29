import 'package:flutter_test/flutter_test.dart';
import 'package:practos6/logic/permissions.dart';
import 'package:practos6/models/appointment.dart';
import 'package:practos6/models/order.dart';
import 'package:practos6/models/review.dart';
import 'package:practos6/models/role.dart';

void main() {
  group('final project models', () {
    test('Order parses server payload', () {
      final order = Order.fromJson({
        'id': 7,
        'customerId': 1,
        'animalId': 2,
        'customerName': 'Test',
        'animalName': 'Cat',
        'quantity': 2,
        'unitPrice': 1000.0,
        'discountPercent': 5,
        'total': 1900.0,
        'status': 'paid',
        'notes': 'ok',
        'createdAt': '2026-10-29T10:00:00.000Z',
      });
      expect(order.id, 7);
      expect(order.total, 1900);
      expect(order.discountPercent, 5);
      expect(order.status, 'paid');
      expect(order.createdAt, isNotNull);
    });

    test('Appointment and Review parse payload', () {
      final appointment = Appointment.fromJson({
        'id': 3,
        'customerId': 1,
        'animalId': 2,
        'vetId': 4,
        'vetName': 'Vet',
        'scheduledAt': '2026-11-01T12:30:00.000Z',
        'durationMinutes': 30,
        'status': 'planned',
      });
      expect(appointment.vetId, 4);
      expect(appointment.durationMinutes, 30);
      expect(appointment.scheduledAt, isNotNull);

      final review = Review.fromJson({
        'id': 5,
        'userId': 3,
        'animalId': 2,
        'rating': 5,
        'text': 'Great',
      });
      expect(review.rating, 5);
      expect(review.animalId, 2);
    });

    test('new routes follow role permissions', () {
      expect(canOpenPath(Role.specialist, '/orders'), isTrue);
      expect(canOpenPath(Role.admin, '/orders'), isFalse);
      expect(canOpenPath(Role.specialist, '/appointments'), isTrue);
      expect(canOpenPath(Role.customer, '/appointments'), isFalse);
      expect(canOpenPath(Role.customer, '/reviews'), isTrue);
      expect(canOpenPath(Role.admin, '/reviews'), isFalse);
    });
  });
}
