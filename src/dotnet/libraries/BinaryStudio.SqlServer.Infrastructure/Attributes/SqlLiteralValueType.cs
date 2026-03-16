using System.ComponentModel;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    /// <summary>
    /// Defines different types of the value of a literal expression.
    /// </summary>
    [TypeConverter(typeof(SqlEnumConverter<SqlLiteralValueType>))]
    public enum SqlLiteralValueType
        {
        /// <summary>
        /// Specifies that the underlying type of the expression is binary data type.
        /// </summary>
        Binary,
        /// <summary>
        /// Specifies that the literal expression is 'DEFAULT' keyword.
        /// </summary>
        Default,
        /// <summary>
        /// Specifies that the literal expression was specified as an identifier (e.g. [abc]).
        /// </summary>
        Identifier,
        /// <summary>
        /// Specifies that the underlying type of the expression one of the integral types.
        /// </summary>
        Integer,
        /// <summary>
        /// Specifies that the underlying type of the expression is image data type.
        /// </summary>
        Image,
        /// <summary>
        /// Specifies that the underlying type of the expression is money data type.
        /// </summary>
        Money,
        /// <summary>
        /// Specifies that the literal expression is the value 'NULL'.
        /// </summary>
        Null,
        /// <summary>
        /// Specifies that the underlying type of the expression is numeric data type.
        /// </summary>
        Numeric,
        /// <summary>
        /// Specifies that the underlying type of the expression is either real or float data type.
        /// </summary>
        Real,
        /// <summary>Specifies string literal expression.</summary>
        String,
        /// <summary>Specifies unicode string literal expression.</summary>
        UnicodeString,
        /// <summary>MAX context sensitive keyword is used.</summary>
        Max,
        /// <summary>ODBC format literals in curly braces { }.</summary>
        ODBC
        }
    }