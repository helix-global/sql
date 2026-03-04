using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptParameterOption : SqlScriptCodeObject<SqlParameterOption>
        {
        public SqlParameterOptionType Type { get { return Source.Type; }}

        #region ctor{IServiceProvider,SqlParameterOption}
        public SqlScriptParameterOption(IServiceProvider context,SqlParameterOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }