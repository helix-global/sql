using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptFillFactorIndexOption : SqlScriptIndexOption<SqlFillFactorIndexOption>
        {
        public Int32 FillFactor {get{ return Source.FillFactor; }}

        #region ctor{IServiceProvider,SqlFillFactorIndexOption}
        public SqlScriptFillFactorIndexOption(IServiceProvider context,SqlFillFactorIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }