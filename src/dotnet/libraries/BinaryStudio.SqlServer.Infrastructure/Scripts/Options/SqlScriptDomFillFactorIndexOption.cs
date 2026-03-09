using System;
using System.Text;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptDomFillFactorIndexOption : SqlScriptDomIndexExpressionOption
        {
        public Int32 FillFactor { get; }

        #region ctor{IServiceProvider,IndexExpressionOption}
        public SqlScriptDomFillFactorIndexOption(IServiceProvider context,IndexExpressionOption source)
            : base(context,source)
            {
            if (source.OptionKind != IndexOptionKind.FillFactor) { throw new ArgumentOutOfRangeException(nameof(source)); }
            FillFactor = (Int32)PropSI4(((IntegerLiteral)source.Expression).Value);
            }
        #endregion

        #region M:ToString:String
        public override String ToString()
            {
            var r = new StringBuilder();
            r.Append($"FillFactor: {FillFactor}");
            return r.ToString();
            }
        #endregion
        }
    }
