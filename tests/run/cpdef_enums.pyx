"""
>>> import sys

>>> ONE, TEN, HUNDRED
(1, 10, 100)
>>> THOUSAND        # doctest: +ELLIPSIS
Traceback (most recent call last):
NameError: ...name 'THOUSAND' is not defined

>>> TWO == 2 or TWO
True
>>> THREE == 3 or THREE
True
>>> FIVE == 5 or FIVE
True
>>> ELEVEN == 11 or ELEVEN
True
>>> SEVEN           # doctest: +ELLIPSIS
Traceback (most recent call last):
NameError: ...name 'SEVEN' is not defined

>>> FOUR == 4 or FOUR
True
>>> EIGHT == 8 or EIGHT
True
>>> SIXTEEN        # doctest: +ELLIPSIS
Traceback (most recent call last):
NameError: ...name 'SIXTEEN' is not defined

>>> RANK_0 == 11 or RANK_0
True
>>> RANK_1 == 37 or RANK_1
True
>>> RANK_2 == 389 or RANK_2
True
>>> RANK_6 == 159 or RANK_6
True
>>> RANK_7 == 889 or RANK_7
True
>>> RANK_3         # doctest: +ELLIPSIS
Traceback (most recent call last):
NameError: ...name 'RANK_3' is not defined

>>> set(PyxEnum) == {TWO, THREE, FIVE}
True
>>> str(PyxEnum.TWO).split(".")[-1]  if sys.version_info < (3,11) else  "TWO" # Py3.10/11 changed the output here
'TWO'
>>> str(PyxEnum.TWO)  if sys.version_info >= (3,11) else  "2" # Py3.10/11 changed the output here
'2'
>>> PyxEnum.TWO + PyxEnum.THREE == PyxEnum.FIVE
True
>>> PyxEnum(2) is PyxEnum["TWO"] is PyxEnum.TWO
True

# not leaking into module namespace
>>> IntEnum        # doctest: +ELLIPSIS
Traceback (most recent call last):
NameError: ...name 'IntEnum' is not defined
"""

cdef extern from *:
    cpdef enum: # ExternPyx
        ONE "1"
        TEN "10"
        HUNDRED "100"

    cdef enum: # ExternSecretPyx
        THOUSAND "1000"

cpdef enum PyxEnum:
    TWO = 2
    THREE = 3
    FIVE = 5

cpdef enum cpdefPyxDocEnum:
    """Home is where...
    """
    ELEVEN = 11

cpdef enum cpdefPyxDocLineEnum:
    """Home is where..."""
    FOURTEEN = 14

cdef enum SecretPyxEnum:
    SEVEN = 7

cdef enum cdefPyxDocEnum:
    """the heart is.
    """
    FIVE_AND_SEVEN = 5077


def test_as_variable_from_cython():
    """
    >>> test_as_variable_from_cython()
    """
    assert list(PyxEnum) == [TWO, THREE, FIVE], list(PyxEnum)
    assert list(PxdEnum) == [RANK_0, RANK_1, RANK_2], list(PxdEnum)

cdef int verify_pure_c() nogil:
    cdef int x = TWO
    cdef int y = PyxEnum.THREE
    cdef int z = SecretPyxEnum.SEVEN
    return x + y + z

# Use it to suppress warning.
verify_pure_c()

def verify_resolution_GH1533():
    """
    >>> verify_resolution_GH1533()
    3
    """
    THREE = 100
    return int(PyxEnum.THREE)


def check_docs():
    """
    >>> PxdEnum.__doc__ not in ("Home is where...\\n    ", "Home is where...")
    True
    >>> PyxEnum.__doc__ not in ("Home is where...\\n    ", "Home is where...")
    True
    >>> cpdefPyxDocEnum.__doc__ == "Home is where...\\n    "
    True
    >>> cpdefPxdDocEnum.__doc__ == "Home is where...\\n    "
    True
    >>> cpdefPyxDocLineEnum.__doc__
    'Home is where...'
    >>> cpdefPxdDocLineEnum.__doc__
    'Home is where...'
    """
    pass


def to_from_py_conversion(PxdEnum val):
    """
    >>> to_from_py_conversion(RANK_1) is PxdEnum.RANK_1
    True

    C enums are commonly enough used as flags that it seems reasonable
    to allow it in Cython
    >>> to_from_py_conversion(RANK_1 | RANK_2) == (RANK_1 | RANK_2)
    True
    """
    return val


def test_pickle():
    """
    >>> from pickle import loads, dumps
    >>> import sys

    Pickling enums won't work without the enum module, so disable the test
    (now requires  3.6 for IntFlag)
    >>> if sys.version_info < (3, 6):
    ...     loads = dumps = lambda x: x
    >>> loads(dumps(PyxEnum.TWO)) == PyxEnum.TWO
    True
    >>> loads(dumps(PxdEnum.RANK_2)) == PxdEnum.RANK_2
    True
    """
    pass

def test_as_default_value(PxdEnum val=PxdEnum.RANK_1):
    """
    In order to work, this requires the utility code to be evaluated
    before the function definition
    >>> test_as_default_value()
    True
    >>> test_as_default_value(PxdEnum.RANK_2)
    False
    >>> test_as_default_value.__defaults__[0] == PxdEnum.RANK_1
    True
    """
    return val == PxdEnum.RANK_1
