#!/usr/bin/env python3
"""
Demo application for Cloud Native Buildpacks presentation.
Uses bcrypt (native library) to demonstrate multi-architecture builds.
"""

import platform
import os
import json
from flask import Flask, request, jsonify
import bcrypt

app = Flask(__name__)

@app.route('/')
def home():
    """Home endpoint with system information."""
    return jsonify({
        "message": "Buildpacks Multi-Architecture Demo",
        "architecture": platform.machine(),
        "platform": platform.platform(),
        "python_version": platform.python_version(),
        "bcrypt_version": bcrypt.__version__ if hasattr(bcrypt, '__version__') else 'available'
    })

@app.route('/hash', methods=['POST'])
def hash_password():
    """Hash a password using bcrypt (demonstrates native library usage)."""
    data = request.get_json()
    
    if not data or 'password' not in data:
        return jsonify({"error": "Password is required"}), 400
    
    password = data['password']
    
    # Generate salt and hash the password
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    
    return jsonify({
        "message": "Password hashed successfully",
        "hash": hashed.decode('utf-8'),
        "architecture": platform.machine(),
        "bcrypt_working": True
    })

@app.route('/verify', methods=['POST'])
def verify_password():
    """Verify a password against its hash."""
    data = request.get_json()
    
    if not data or 'password' not in data or 'hash' not in data:
        return jsonify({"error": "Password and hash are required"}), 400
    
    password = data['password']
    hash_to_check = data['hash']
    
    try:
        # Verify the password
        is_valid = bcrypt.checkpw(password.encode('utf-8'), hash_to_check.encode('utf-8'))
        
        return jsonify({
            "message": "Password verification completed",
            "valid": is_valid,
            "architecture": platform.machine()
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route('/health')
def health_check():
    """Health check endpoint."""
    return jsonify({
        "status": "healthy",
        "architecture": platform.machine(),
        "native_libs_working": True
    })

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)