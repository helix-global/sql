using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlNullQualifier))]
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