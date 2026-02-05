<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\VehiculeController;
use App\Http\Controllers\ReparationController;
use App\Http\Controllers\TechnicienController;

// Route pour créer une réparation avec un véhicule pré-sélectionné
Route::get('/reparations/create', [ReparationController::class, 'create'])
    ->name('reparations.create')
    ->defaults('vehicule_id', null);

Route::get('/reparations/create/{vehicule}', function ($vehicule_id) {
    return app(ReparationController::class)->create(request())->with('vehicule_id', $vehicule_id);
})->name('reparations.create.for.vehicule');

// Page d'accueil
Route::get('/', function () {
    return view('dashboard');
})->name('dashboard');

// Routes CRUD pour les 3 ressources
Route::resource('vehicules', VehiculeController::class);
Route::resource('reparations', ReparationController::class);
Route::resource('techniciens', TechnicienController::class);

// Routes API
Route::prefix('api')->group(function () {
    Route::apiResource('vehicules', \App\Http\Controllers\Api\VehiculeController::class);
    Route::apiResource('reparations', \App\Http\Controllers\Api\ReparationController::class);
    Route::apiResource('techniciens', \App\Http\Controllers\Api\TechnicienController::class);
});
