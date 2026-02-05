<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\VehiculeController;
use App\Http\Controllers\Api\ReparationController;
use App\Http\Controllers\Api\TechnicienController;

// API Routes
Route::prefix('v1')->group(function () {

    // Véhicules
    Route::get('/vehicules', [VehiculeController::class, 'index']);
    Route::post('/vehicules', [VehiculeController::class, 'store']);
    Route::get('/vehicules/{id}', [VehiculeController::class, 'show']);
    Route::put('/vehicules/{id}', [VehiculeController::class, 'update']);
    Route::delete('/vehicules/{id}', [VehiculeController::class, 'destroy']);

    // Réparations
    Route::get('/reparations', [ReparationController::class, 'index']);
    Route::post('/reparations', [ReparationController::class, 'store']);
    Route::get('/reparations/{id}', [ReparationController::class, 'show']);
    Route::put('/reparations/{id}', [ReparationController::class, 'update']);
    Route::delete('/reparations/{id}', [ReparationController::class, 'destroy']);

    // Techniciens
    Route::get('/techniciens', [TechnicienController::class, 'index']);
    Route::post('/techniciens', [TechnicienController::class, 'store']);
    Route::get('/techniciens/{id}', [TechnicienController::class, 'show']);
    Route::put('/techniciens/{id}', [TechnicienController::class, 'update']);
    Route::delete('/techniciens/{id}', [TechnicienController::class, 'destroy']);

    // Routes supplémentaires
    Route::get('/vehicules/{id}/reparations', function ($id) {
        $vehicule = \App\Models\Vehicule::with('reparations.techniciens')->find($id);

        if (!$vehicule) {
            return response()->json([
                'success' => false,
                'message' => 'Véhicule non trouvé'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $vehicule->reparations
        ]);
    });

    Route::get('/techniciens/{id}/reparations', function ($id) {
        $technicien = \App\Models\Technicien::with('reparations.vehicule')->find($id);

        if (!$technicien) {
            return response()->json([
                'success' => false,
                'message' => 'Technicien non trouvé'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $technicien->reparations
        ]);
    });
});
