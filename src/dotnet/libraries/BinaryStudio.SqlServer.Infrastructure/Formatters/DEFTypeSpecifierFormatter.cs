using System;
using System.IO;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class DEFTypeSpecifierFormatter : SqlObjectFormatter<ISqlTypeSpecifier>
        {
        private const Int32 DEFAULT_FLOAT_PRECISION   = 53;
        private const Int32 DEFAULT_DECIMAL_PRECISION = 18;
        private const Int32 DEFAULT_DECIMAL_SCALE     = 0;
        private const Int32 DEFAULT_TIME_SCALE        = 7;

        public static readonly ISqlObjectFormatter<ISqlTypeSpecifier> Instance = new SSDTTypeSpecifierFormatter();

        #region M:WriteTo(IServiceProvider,ISqlTypeSpecifier,TextWriter)
        public override void WriteTo(IServiceProvider provider,ISqlTypeSpecifier source,TextWriter target)
            {
            if (source.Type != SqlDataType.None) {
                switch (source.Type) {
                    case SqlDataType.Variant:
                        target.Write("sql_variant");
                        break;
                    default:
                        target.Write(source.Type.ToString().ToLowerInvariant());
                        break;
                    }
                switch (source.Type) {
                    case SqlDataType.Time:
                    case SqlDataType.DateTime2:
                    case SqlDataType.DateTimeOffset:
                        if ((source.Scale != DEFAULT_TIME_SCALE) && (source.Scale != null)) {
                            target.Write($"({source.Scale.Value})");
                            }
                        break;
                    case SqlDataType.Float:
                        if ((source.Precision != DEFAULT_FLOAT_PRECISION) && (source.Precision != null)) {
                            target.Write($"({source.Precision})");
                            }
                        break;
                    case SqlDataType.Decimal:
                    case SqlDataType.Numeric:
                        if (source.Scale == DEFAULT_DECIMAL_SCALE) {
                            if (source.Precision != DEFAULT_DECIMAL_PRECISION)
                                {
                                target.Write($"({source.Precision})");
                                }
                            }
                        else
                            {
                            target.Write($"({source.Precision},{source.Scale})");
                            }
                        break;
                    case SqlDataType.VarBinary:
                    case SqlDataType.VarChar:
                    case SqlDataType.NVarChar:
                        if (source.IsMaximum || (source.Length == -1)) {
                            target.Write($"(max))");
                            }
                        else
                            {
                            target.Write($"({source.Length})");
                            }
                        break;
                    case SqlDataType.NChar:
                    case SqlDataType.Char:
                    case SqlDataType.Binary:
                        target.Write($"({source.Length})");
                        break;
                    }
                }
            }
        #endregion
        }
    }
