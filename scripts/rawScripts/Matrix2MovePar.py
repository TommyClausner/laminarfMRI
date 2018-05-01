#!/usr/bin/env python
"""
This function clones Matrix2MovePar used by FSL to convert transformation matrices to vectors
"""

import numpy as np
import sys


def make_rot(angl, cntr):
    """This function clones MISCMATHS::make_rot"""
    rot = np.identity(4)

    theta = np.linalg.norm(angl, 2)

    if theta < 1e-8:
        theta = 1e-8

    axis = angl / theta
    x1 = axis
    x2 = np.zeros(3)
    x2[0] = -axis[1]
    x2[1] = axis[0]
    x2[2] = 0

    if np.linalg.norm(x2, 2) <= 0:
        x2[0] = 1.0
        x2[1] = 0.0
        x2[2] = 0.0

    x2 = x2 / np.linalg.norm(x2, 2)
    x3 = np.cross(x1, x2)
    x3 = x3 / np.linalg.norm(x3, 2)

    basischange = np.zeros((3, 3))
    basischange[0:3, 0] = x2
    basischange[0:3, 1] = x3
    basischange[0:3, 2] = x1

    rotcore = np.identity(3)
    rotcore[0, 0] = np.cos(theta)
    rotcore[1, 1] = np.cos(theta)
    rotcore[0, 1] = np.sin(theta)
    rotcore[1, 0] = -np.sin(theta)

    rot[0:3, 0:3] = np.dot(basischange, np.dot(rotcore, np.transpose(basischange)))

    trans = np.dot((np.identity(3) - rot[0:3, 0:3]), cntr)
    rot[0:3, 3] = trans

    return rot


def construct_rotmat_euler(tmp, cntr):
    """This function clones MISCMATHS::construct_rotmat_euler"""
    aff = np.identity(4)

    angl = np.zeros(3)
    angl[0] = tmp[0]

    newaff = make_rot(angl, cntr)
    aff = aff * newaff

    angl = np.zeros(3)
    angl[1] = tmp[1]
    newaff = make_rot(angl, cntr)
    aff = aff * newaff

    angl = np.zeros(3)
    angl[1] = tmp[1]
    newaff = make_rot(angl, cntr)
    aff = aff * newaff

    aff[0, 3] += tmp[3]
    aff[1, 3] += tmp[4]
    aff[2, 3] += tmp[5]

    return aff


def MovePar2Matrix(mp, vol):
    """This function clones TOPUP::MovePar2Matrix"""
    tmp = np.zeros(6)
    cntr = np.zeros(3)
    tmp[0] = mp[3]
    tmp[1] = mp[4]
    tmp[2] = mp[5]
    tmp[3] = mp[0]
    tmp[4] = mp[1]
    tmp[5] = mp[2]

    cntr[0] = ((vol[0] - 1) * vol[3]) / 2
    cntr[1] = ((vol[1] - 1) * vol[4]) / 2
    cntr[2] = ((vol[2] - 1) * vol[5]) / 2

    mat = construct_rotmat_euler(tmp, cntr)

    return mat


def rotmat2euler(M):
    """This function clones MISCMATHS::rotmat2euler"""
    angles = np.zeros(3)
    cy = np.sqrt(M[0, 0] ** 2 + M[0, 1] ** 2)
    if cy < 1e-4:
        cx = M[1, 1]
        sx = -M[2, 1]
        sy = -M[0, 2]
        angles[0] = np.arctan2(sx, cx)
        angles[1] = np.arctan2(sy, 0)
        angles[2] = 0
    else:
        cz = M[0, 0] / cy
        sz = M[0, 1] / cy
        cx = M[2, 2] / cy
        sx = M[1, 2] / cy
        sy = -M[0, 2]
        angles[0] = np.arctan2(sx, cx)
        angles[1] = np.arctan2(sy, cy)
        angles[2] = np.arctan2(sz, cz)
    return angles


def Matrix2MovePar(M, vol):
    """This function clones TOPUP::Matrix2MovePar"""
    mp = np.zeros(6)
    mp[3:6] = rotmat2euler(M)

    MM = MovePar2Matrix(mp, vol)
    mp[0:3] = M[0:3, 3] - MM[0:3, 3]

    return mp


def do_it():
    """execution of Matrix2MovePar.py"""
    file_ = np.asanyarray(sys.argv[1])
    vol = sys.argv[2].split()
    vol = np.asanyarray(map(float, vol))
    fileHandle = open(file_, 'r')

    newmat = []

    for line in fileHandle:
        fields = line.split()
        newmat.append(map(float, fields))
    fileHandle.close()
    newmat = np.asanyarray(newmat)
    mp = Matrix2MovePar(newmat, vol)
    outstring = [str(m) for m in mp]
    print('\t'.join(outstring))


do_it()
sys.exit()

