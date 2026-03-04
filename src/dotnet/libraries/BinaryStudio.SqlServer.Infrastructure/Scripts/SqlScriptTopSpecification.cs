using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlTopSpecification))]
    internal sealed class SqlScriptTopSpecification : SqlScriptCodeObject<SqlTopSpecification>
        {
        public Boolean IsPercent { get { return Source.IsPercent; }}
        public Boolean IsWithTies { get { return Source.IsWithTies; }}

        #region ctor{IServiceProvider,SqlTopSpecification}
        public SqlScriptTopSpecification(IServiceProvider context,SqlTopSpecification source)
            : base(context,source)
            {
            }
        #endregion
        }
    }