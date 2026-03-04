using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptOnlineIndexOption : SqlScriptIndexOption<SqlOnlineIndexOption>
        {
        public SqlOnOffValue OnOffValue { get { return Source.OnOffValue; }}

        #region ctor{IServiceProvider,SqlOnlineIndexOption}
        public SqlScriptOnlineIndexOption(IServiceProvider context,SqlOnlineIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }