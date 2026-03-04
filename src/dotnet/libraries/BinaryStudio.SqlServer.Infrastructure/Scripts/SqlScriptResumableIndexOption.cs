using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptResumableIndexOption : SqlScriptIndexOption<SqlResumableIndexOption>
        {
        public SqlOnOffValue OnOffValue { get { return Source.OnOffValue; }}

        #region ctor{IServiceProvider,SqlResumableIndexOption}
        public SqlScriptResumableIndexOption(IServiceProvider context,SqlResumableIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }