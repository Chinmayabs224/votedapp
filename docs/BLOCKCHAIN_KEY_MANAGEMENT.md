# Blockchain Key Management Guide

## Overview

This document provides instructions on how to manage blockchain keys in the Secure Voting System, including generating new key pairs, importing/exporting keys, and best practices for key security.

## Key Management Interface

The Key Management interface is accessible from the Admin section of the application. It allows you to:

- View all your blockchain keys
- Generate new key pairs
- Import existing keys
- Export keys for backup
- Activate/deactivate keys

## Generating Private Keys

Follow these steps to generate a new blockchain key pair:

1. **Access the Key Management Screen**:
   - Log in to the application with admin credentials
   - Navigate to the Admin section
   - Click on "Key Management" in the sidebar menu

2. **Generate a New Key**:
   - Click the "Generate New Key" button
   - Enter a descriptive name for your key (e.g., "Election Admin Key 2023")
   - Click "Generate Key Pair"

3. **Save Your Keys**:
   - Once generated, your public and private keys will be displayed
   - The public key can be shared and will be used to verify your identity on the blockchain
   - The private key must be kept secure and will be used to sign transactions
   - Use the copy buttons to copy the keys to your clipboard if needed

4. **Return to Key Management**:
   - Click "Back to Key Management" to return to the main key management screen
   - Your new key will be listed and activated by default

## Key Security Best Practices

1. **Private Key Protection**:
   - Never share your private key with anyone
   - Store backups of your private key in secure, offline locations
   - Consider using hardware security modules for critical keys

2. **Key Rotation**:
   - Regularly generate new keys for sensitive operations
   - Deactivate old keys when they are no longer needed

3. **Access Control**:
   - Limit access to the key management interface to authorized personnel only
   - Use strong passwords and two-factor authentication for your admin account

4. **Backup Procedures**:
   - Regularly export and backup your keys
   - Store backups in multiple secure locations
   - Test key restoration procedures periodically

## Technical Details

The Secure Voting System uses Elliptic Curve Digital Signature Algorithm (ECDSA) with the secp256k1 curve for blockchain key generation, which is the same cryptographic algorithm used by many popular blockchain platforms.

- **Private Key**: A randomly generated 32-byte (256-bit) number
- **Public Key**: Derived from the private key using elliptic curve multiplication
- **Key Format**: Keys are encoded in base64 format for display and storage

## Troubleshooting

If you encounter issues with key generation or management:

1. **404 Not Found Error**:
   - Ensure you're using the latest version of the application
   - Clear your browser cache and cookies
   - Try accessing the page again

2. **Key Generation Failures**:
   - Check your internet connection
   - Ensure your browser is up-to-date
   - Try using a different browser if issues persist

3. **Import/Export Issues**:
   - Verify that the key data is complete and not corrupted
   - Ensure you're copying the entire key string

For additional assistance, contact your system administrator or the development team.