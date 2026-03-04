using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptForXmlUnknownDirective : SqlScriptForXmlDirective<SqlForXmlUnknownDirective>
        {
        public String Name {get{ return Source.Name; }}

        #region ctor{IServiceProvider,SqlForXmlUnknownDirective}
        public SqlScriptForXmlUnknownDirective(IServiceProvider context,SqlForXmlUnknownDirective source)
            : base(context,source)
            {
            }
        #endregion
        }
    }