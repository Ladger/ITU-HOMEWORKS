"""
BLG202E Term Project
Berk Özcan
150220107
"""

import numpy as np
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
import sys

def qr_decomposition(matrix): # Implementation of the QR Decomposition in linear algebra
    first_vector = matrix[:, 0].reshape(-1, 1)
    second_vector = matrix[:, 1].reshape(-1, 1)
    third_vector = matrix[:, 2].reshape(-1, 1)

    e1 = first_vector
    e2 = second_vector - ((np.dot(e1.T, second_vector)) / (np.dot(e1.T, e1))) * e1        
    e3 = third_vector - ((np.dot(e1.T, third_vector)) / (np.dot(e1.T, e1))) * e1 - ((np.dot(e2.T, third_vector)) / (np.dot(e2.T, e2))) * e2
    
    q1 = e1 / np.linalg.norm(e1)
    q2 = e2 / np.linalg.norm(e2)
    q3 = e3 / np.linalg.norm(e3)

    Q = np.concatenate((q1, q2, q3), axis=1)

    R = np.dot(Q.T, matrix)

    return Q,R

def get_eig(matrix): # QR algorithm that provides to find eigenvalues and eigenvectors

    eigenvectors = np.identity(3)
    for i in range(30): # An iteration that converges to the right result of eigenvalues
        Q,R = qr_decomposition(matrix)
        matrix = np.dot(R,Q)
        eigenvectors = np.dot(eigenvectors, Q) # Cumulative multiplication of Q matrix gives us the matrix that contains eigenvectors
    
    eigenvalues = np.diag(matrix)
    
    return eigenvalues, eigenvectors

def sv_decompostion(matrix): # Implementation of SV Decomposition in linear algebra
    rank = np.linalg.matrix_rank(matrix)
    ata_matrix = np.dot(np.transpose(matrix), matrix)

    eigenvalues, eigenvectors = get_eig(ata_matrix) # Getting eig

    singular_values = [np.sqrt(float(singval)) for singval in eigenvalues]
    singular_values.sort(reverse=True)
    m, n = ata_matrix.shape
    
    # Finding E matrix
    sigma = np.zeros((m, n))
    for i in range(rank):
        for j in range(rank):
            if (i != j):
                continue
            sigma[i][j] = singular_values[i]
    
    # Finding Vt matrix and normalizing the eigenvectors
    sort_base_on_eigenvalues = np.argsort(eigenvalues)[::-1]
    sorted_eigenvectors = eigenvectors[:, sort_base_on_eigenvalues]
    Vt = np.transpose(sorted_eigenvectors)
    for i in range(rank):
        normalize = 0
        for j in range(n):
            normalize += Vt[i][j]**2
        np.sqrt(normalize)
        for j in range(n):
            Vt[i][j] *= 1/normalize
    
    # Finding U matrix
    U = np.empty((m, 0))
    for i in range(rank):
        vector = 1/sigma[i][i] * np.dot(matrix, np.transpose(Vt[i]))
        U = np.hstack((U, vector.reshape(-1, 1)))

    return U, sigma, Vt

def get_matrices_from_dataset(): # Read the dataset and return a matrix

    mat1_file = sys.argv[1]
    mat2_file = sys.argv[2]
    correspondences_file = sys.argv[3]

    with open(mat1_file,'r') as mat1:
        dataset = mat1.readlines()

    mat1_matrix = []
    with open(mat1_file, 'r') as file:
        for line in file:
            coordinates = [float(axis) for axis in line.split()] # Creating sublists for separate coordinates
            mat1_matrix.append(coordinates)

    mat2_matrix = []
    with open(mat2_file, 'r') as file:
        for line in file:
            coordinates = [float(axis) for axis in line.split()] # Creating sublists for separate coordinates
            mat2_matrix.append(coordinates)

    correspondences = []
    with open(correspondences_file, 'r') as file:
        for line in file:
            corrs = [float(correspond) for correspond in line.split()]
            correspondences.append(corrs)

    # Matching row index of corresponding points in the file
    Q = []
    P = []
    for row in correspondences:
        Q.append(mat1_matrix[int(row[0])])
        P.append(mat2_matrix[int(row[1])])

    return np.array(Q).T, np.array(P).T

Q_matrix, P_matrix = get_matrices_from_dataset()

M_matrix = np.dot(Q_matrix, np.transpose(P_matrix))

U,E,Vt = sv_decompostion(M_matrix)


# Implementation of the Kabsch-Umeyama Algorithm
E_tilde = E
m_matrix_rank = np.linalg.matrix_rank(M_matrix)
for row in range(m_matrix_rank):
    for column in range(m_matrix_rank):
        if (row != column):
            continue
        elif (row == column and row == m_matrix_rank - 1):
            if (np.linalg.det(np.dot(U,np.transpose(Vt))) > 0):
                E_tilde[row][column] = 1
            else:
                E_tilde[row][column] = -1
                break
        
        E_tilde[row][column] = 1

rotation_matrix = np.dot(U,np.dot(E_tilde, Vt))
translation_vector = P_matrix.mean(axis=1, keepdims=True) - np.dot(rotation_matrix, Q_matrix.mean(axis=1, keepdims=True))

translated_P_matrix =  np.dot(rotation_matrix.T, P_matrix - translation_vector)

merged_matrix = np.concatenate((Q_matrix, translated_P_matrix), axis=1)

# Saving results
np.savetxt('rotation_matrix.txt', rotation_matrix.T, delimiter='\t')
np.savetxt('translation_vec.txt', translation_vector.T, delimiter='\t')
np.savetxt('merged.txt', merged_matrix.T, delimiter='\t') 

# Creating plot
x = merged_matrix[0]
y = merged_matrix[1]
z = merged_matrix[2]

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')

ax.scatter(x, y, z, c='b', marker='o')

ax.set_xlabel('X')
ax.set_ylabel('Y')
ax.set_zlabel('Z')

plt.savefig('plot')
