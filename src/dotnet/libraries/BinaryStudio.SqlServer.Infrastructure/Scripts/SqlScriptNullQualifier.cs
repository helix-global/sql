using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptNullQualifier : SqlScriptCodeObject<SqlNullQualifier>
        {
        public SqlJsonNullQualifier JsonNullQualifierValue { get { return Source.JsonNullQualifierValue; }}

        #region ctor{IServiceProvider,SqlNullQualifier}
        public SqlScriptNullQualifier(IServiceProvider context,SqlNullQualifier source)
            : base(context,source)
            {
            }
        #endregion
        }
    }